open Doctest

let progname =
  if Array.length Sys.argv > 0 then Sys.argv.(0) else "EXECUTABLE"

type config = {
  libs: string list;
  dirs: string list;
  cmts: string list;
}

let append xs x = xs := x :: !xs

let parse_args () =
  let usage =
    Format.sprintf "Usage: %s [OPTIONS] file1.cmt [file2.cmt ...]" progname
  in
  let cmts = ref [] in
  let dirs = ref [] in
  let libs = ref [] in
  let speclist = [
    "-d", Arg.String (append dirs),
    "directory to load in the ocaml interpreter (via #directory)";
    "-l", Arg.String (append libs),
    "libraries (.cma files) to load in the ocaml interpreter (via #load)";
  ] in
  Arg.parse speclist (append cmts) usage;
  {libs = !libs; dirs = !dirs; cmts = !cmts}

let () =
  let config = parse_args () in

  Toplevel.initialise ~dirs:config.dirs ~libs:config.libs;

  let report =
    List.fold_left
      (fun report filename ->
        File.of_filename filename
        |> Run.file
        |> Run.Report.join report)
      Run.Report.empty
      config.cmts
  in
  let rc = if report.nb_ok < report.nb_tests then 1 else 0 in
  Format.eprintf "[INFO] Total: %a@." Run.Report.pp report;
  exit rc
