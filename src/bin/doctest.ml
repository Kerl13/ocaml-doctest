let parse_args args =
  let nargs = Array.length args in
  if nargs <> 2 then (
    let progname = if nargs = 1 then Sys.argv.(0) else "EXECUTABLE" in
    Format.eprintf "Usage: %s FILE.cmt" progname;
    exit 1
  );
  args.(1)

let () =
  Toploop.initialize_toplevel_env ();
  let filename = parse_args Sys.argv in
  List.iter
    (function
      | Ok doctest -> Doctest.run doctest
      | Error e -> Format.eprintf "[ERROR] %s@." e)
    (Doctest.Collect.from_file filename)
