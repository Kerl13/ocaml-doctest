open Utils

module Report = struct
  type t = {
    nb_tests: int;
    nb_ok: int
  }

  let make ok total =
    if ok < 0 || ok > total then invalid_arg "Run.Report.make";
    {nb_tests = total; nb_ok = ok}

  let empty = make 0 0

  let join r1 r2 = {
    nb_tests = r1.nb_tests + r2.nb_tests;
    nb_ok = r1.nb_ok + r2.nb_ok
  }

  let pp fmt report =
    Format.fprintf fmt "%d / %d tests passed" report.nb_ok report.nb_tests
end

let pp_loc fmt (loc: Odoc_parser.Loc.span) =
  Format.fprintf fmt "File \"%s\", " loc.file;
  if loc.start.line = loc.end_.line
  then Format.fprintf fmt "line %d, " loc.start.line
  else Format.fprintf fmt "lines %d-%d, " loc.start.line loc.end_.line;
  Format.fprintf fmt "characters %d-%d:" loc.start.column loc.end_.column

let comment (comment: Comment.t) : Report.t =
  let ok, total =
    List.fold_left
      (fun (ok, total) (doctest, loc) ->
        match doctest >>= Test.run with
        | Ok () -> (ok + 1, total + 1)
        | Error e ->
          Format.eprintf "[ERROR] %a\n%s@." pp_loc loc e;
          (ok, total + 1))
      (0, 0)
      (Comment.collect_doctests comment)
  in
  let report = Report.make ok total in
  if total > 0 then
    Format.eprintf "[INFO] %a: %a@."
      Location.print_loc (Comment.location comment) Report.pp report;
  report

let file (file: File.t) : Report.t =
  List.fold_left
    (fun report c ->
      Report.join report (comment c))
    Report.empty
    file.comments
