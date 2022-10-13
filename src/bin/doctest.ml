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
    "add a directory to the search path in the ocaml interpreter (via #directory)";
    "-l", Arg.String (append libs),
    "load a .cmo or .cma file in the ocaml interpreter (via #load)";
  ] in
  Arg.parse speclist (append cmts) usage;
  match !cmts, !dirs, !libs with
  | [], [], [] ->
    Arg.usage speclist usage;
    exit 0
  | [], _, _ ->
    Arg.usage speclist usage;
    Format.eprintf "Not enough arguments\n";
    exit 1
  | cmts, dirs, libs -> {libs; dirs; cmts}

let () =
  let config = parse_args () in

  Toplevel.initialise ~dirs:config.dirs ~libs:config.libs;

  let report, err =
    List.fold_left
      (fun (report, err) filename ->
        match File.of_filename filename with
        | Ok file ->
          (file |> Run.file |> Run.Report.join report), err
        | Error msg ->
          Format.eprintf "[ERROR] %s@." msg;
          report, true)
      (Run.Report.empty, false)
      config.cmts
  in
  let rc = if err || report.nb_ok < report.nb_tests then 1 else 0 in
  Format.eprintf "[INFO] Total: %a@." Run.Report.pp report;
  exit rc
