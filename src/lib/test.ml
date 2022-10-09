type instruction = {
  phrase: string;
  expect: string
}

type t = instruction list

let rec find_start_of_phrase s i =
  let i = ExtString.skip_whitespaces s i in
  if i < String.length s && s.[i] = '#' then
    Some i
  else
    match String.index_from_opt s i '\n' with
    | Some i -> find_start_of_phrase s i
    | None -> None

let rec parse instructions s i =
  (* We don't care about leading or trailing whitespaces *)
  let i = ExtString.skip_whitespaces s i in
  if i = String.length s then
    (* We are done *)
    Ok (List.rev instructions)
  else if s.[i] = '#' then (* Start of an instruction *)
    match ExtString.index_from_substring s i ";;" with
    | None -> Error.fail "could not find the end-of-phrase token (;;)"
    | Some j ->
      (* This is a top-level phrase to execute as part of the test. *)
      let phrase = String.sub s (i + 2) (j - i) in
      match String.index_from_opt s (j + 2) '\n' with
      | Some i ->
        (* Expected output of the test *)
        (match find_start_of_phrase s i with
        | Some j ->
          let expect = String.(trim (sub s i (j - i))) in
          parse ({phrase; expect} :: instructions) s j
        | None ->
          let expect = String.(trim (sub s i (String.length s - i))) in
          Ok (List.rev ({phrase; expect} :: instructions)))
      | None ->
        (* We are at the end of the doctest block. No output is expected. *)
        Ok (List.rev ({phrase; expect = ""} :: instructions))
  else (
    Format.eprintf "ERROR: FOUND ===%c=== as position %d@." s.[i] i;
    Error.fail "A top-level phrase must start with a '#'"
  )
let parse s = parse [] s 0

let run (doctests: t) =
  let buffer = Buffer.create 0 in
  let fmt = Format.formatter_of_buffer buffer in
  List.fold_left
    (fun state {phrase; expect} ->
      let open ResultMonadSyntax in
      Buffer.clear buffer;
      let* () =
        let lexbuf = Lexing.from_string phrase in
        try
          if Toploop.(execute_phrase true fmt (!parse_toplevel_phrase lexbuf))
          then Ok ()
          else Error.fail "something went wrong"
        with exn ->
          Location.report_exception fmt exn;
          Ok ()
      in
      let result =
        let got = Buffer.to_bytes buffer |> String.of_bytes in
        if not (ExtString.loose_equality got expect) then
          Error.fail "The following test failed:\n  %s\nExpected:\n  %s\nGot:\n  %s\n"
            phrase expect got
        else
          Ok ()
      in
      match state, result with
      | Ok (), Ok () -> Ok ()
      | (Ok (), (Error _ as err) | (Error _ as err), Ok ()) -> err
      | Error e1, Error e2 -> Error (Error.combine e1 e2))
    (Ok ())
    doctests

(** {2 Pretty printing} *)

let pp_instruction fmt {phrase; expect} =
  Format.fprintf fmt "# %s\n%s" phrase expect

let pp =
  Format.pp_print_list
    ~pp_sep:(fun fmt () -> Format.fprintf fmt "\n")
    pp_instruction
