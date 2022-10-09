open Utils

(* FIXME: dirty hack *)
let __patched_printer = ref false

let initialise ~dirs ~loads =
  (* Initialise the toplevel env *)
  Toploop.initialize_toplevel_env ();
  List.iter Topdirs.dir_directory dirs;
  List.iter
    (fun filename ->
      if not (Toploop.load_file Format.err_formatter filename) then
        panic "could not load file `%s'" filename)
    loads;

  (* FIXME: dirty hack *)
  if not !__patched_printer then (
    (* Configure the error pretty_printer not to display locations. *)
    Location.report_printer := (
      let rp = !Location.report_printer () in
      (fun () -> {rp with pp_main_loc = fun _ _ _ _ -> ()})
    );
    __patched_printer := true
  )
