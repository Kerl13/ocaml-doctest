open Doctest

let progname =
  if Array.length Sys.argv > 0 then Sys.argv.(0) else "EXECUTABLE"

let parse_args () =
  let usage = Format.sprintf "Usage: %s FILE" progname in
  let speclist = [] in
  let arg = ref None in
  let anon_fun filename =
    match !arg with
    | None -> arg := Some filename
    | Some _ ->
      Arg.usage speclist usage;
      Format.eprintf "Too many arguments\n";
      exit 1
  in
  Arg.parse speclist anon_fun usage;
  match !arg with
  | Some filename -> filename
  | None ->
    Format.eprintf "Missing argument: FILE";
    exit 1

let () =
  let file = parse_args () |> File.of_filename in

  Toplevel.initial_setup ();
  match Toplevel.load file with
  | Error error ->
    Format.eprintf "[ERROR] %a@." Error.pp error;
    exit 1
  | Ok () -> ();

  let report = Run.file file in
  Format.printf "Total: %a@." Run.Report.pp report
