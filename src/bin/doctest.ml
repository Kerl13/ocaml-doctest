open Doctest

let parse_args args =
  let nargs = Array.length args in
  if nargs <> 2 then (
    let progname = if nargs = 1 then Sys.argv.(0) else "EXECUTABLE" in
    Format.eprintf "Usage: %s FILE.cmt" progname;
    exit 1
  );
  args.(1)

module Toplevel = struct
  let init () = Toploop.initialize_toplevel_env ()

  let load file =
    let dir, cmo = File.obj_file file in
    Compmisc.init_path ~dir ();
    let ok = Toploop.load_file Format.err_formatter cmo in
    if not ok then
      Error.fail "Could not load %s" cmo
    else Ok ()
end

let (>>=) = Result.bind

let () =
  let file = parse_args Sys.argv |> File.of_filename in

  Toplevel.init ();
  match Toplevel.load file with
  | Error error ->
    Format.eprintf "[ERROR] %a@." Error.pp error
  | Ok () ->
    List.iter
      (fun comment ->
        let ok, total =
          List.fold_left
            (fun (ok, total) doctest ->
              match doctest >>= Test.run with
              | Ok () -> (ok + 1, total + 1)
              | Error e ->
                Format.eprintf "[ERROR] %a@." Error.pp e;
                (ok, total + 1))
            (0, 0)
            (Comment.collect_doctests comment)
        in
        if total > 0 then
          Format.printf "At %a: %d / %d doctests passed\n"
            Location.print_loc (Comment.location comment) ok total)
      (File.collect_doc_comments file)
