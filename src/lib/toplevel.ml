let initial_setup () =
  (* Initialise the toplevel env *)
  Toploop.initialize_toplevel_env ();

  (* Configure the error pretty_printer not to display locations. *)
  Location.report_printer :=
    let rp = !Location.report_printer () in
    (fun () -> {rp with pp_main_loc = fun _ _ _ _ -> ()})

let load file =
  let dir, cmo = File.obj_file file in
  Compmisc.init_path ~dir ();
  let ok = Toploop.load_file Format.err_formatter cmo in
  if not ok then
    Error.fail "Could not load %s" cmo
  else Ok ()
