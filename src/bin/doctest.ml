open Doctest

let parse_args args =
  let nargs = Array.length args in
  if nargs <> 2 then (
    let progname = if nargs = 1 then Sys.argv.(0) else "EXECUTABLE" in
    Format.eprintf "Usage: %s FILE.cmt" progname;
    exit 1
  );
  args.(1)

let (>>=) = Result.bind

let handle_comment comment =
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
      Location.print_loc (Comment.location comment) ok total

let () =
  let file = parse_args Sys.argv |> File.of_filename in

  Toplevel.initial_setup ();
  match Toplevel.load file with
  | Error error ->
    Format.eprintf "[ERROR] %a@." Error.pp error;
    exit 1
  | Ok () -> ();

  let comments = File.collect_doc_comments file in
  List.iter handle_comment comments
