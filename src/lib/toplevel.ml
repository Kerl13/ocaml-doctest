open Utils

(* FIXME: dirty hack *)
let patch_printer =
  let patched = ref false in
  fun () ->
    if not !patched then (
      (* Configure the error pretty_printer not to display locations. *)
      Location.report_printer := (
        let rp = !Location.report_printer () in
        (fun () -> {rp with pp_main_loc = fun _ _ _ _ -> ()})
      );
      patched := true
    )

let add_directory =
  let tbl = Hashtbl.create 7 in
  fun path ->
    if Hashtbl.mem tbl path then ()
    else (
      Topdirs.dir_directory path;
      Hashtbl.add tbl path ()
    )

let initialise ~dirs ~libs =
  (* Initialise the toplevel env *)
  Toploop.initialize_toplevel_env ();
  List.iter add_directory dirs;
  List.iter
    (fun filename ->
      add_directory (Filename.dirname filename);
      if not (Toploop.load_file Format.err_formatter filename) then
        panic "could not load file `%s'" filename)
    libs;
  patch_printer ()
