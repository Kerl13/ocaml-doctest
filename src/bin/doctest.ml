open Doctest

let progname =
  if Array.length Sys.argv > 0 then Sys.argv.(0) else "EXECUTABLE"

let usage =
  Format.sprintf "Usage: %s [OPTIONS] file1.cmt [file2.cmt ...]" progname

let version = "0.1.0-alpha"

type config = {
  libs: string list;
  dirs: string list;
  cmts: string list;
}

let append xs x = xs := x :: !xs

let make_speclist =
  List.fold_left
    (fun speclist (short, long, spec, doc) ->
      (Format.sprintf "-%c" short, spec, doc)
      :: (Format.sprintf "--%s" long, spec, doc)
      ::speclist)
    []

let parse_args () =
  let cmts = ref [] in
  let dirs = ref [] in
  let libs = ref [] in
  let print_version = ref false in

  let speclist = make_speclist [
    'd', "directory", Arg.String (append dirs),
    "add a directory to the search path of the ocaml toplevel (via #directory)";
    'l', "load", Arg.String (append libs),
    "load a .cmo or .cma file in the ocaml interpreter (via #load)";
    'v', "version", Arg.Set print_version, "print the version and exit"
  ] in

  Arg.parse speclist (append cmts) usage;
  if !print_version then (
    Format.printf "doctest version %s\n" version;
    exit 0
  );

  match List.rev !cmts, List.rev !dirs, List.rev !libs with
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
        match File.parse filename with
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
