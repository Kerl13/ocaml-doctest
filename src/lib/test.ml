open Utils

type item = {
  phrase: Parsetree.toplevel_phrase;
  expect: string
}

type t = item list

(** {2 Pretty printing} *)

(* Work around the ulgy ";;" that Pprintast.toplevel_phrase puts at the
   beginning of eval statements. *)
let pp_phrase fmt phrase =
  let s = Format.asprintf "%a" Pprintast.toplevel_phrase phrase in
  let len = String.length s in
  if len > 2 && String.starts_with ~prefix:";;" s then
    Format.pp_print_string fmt (String.sub s 2 (len - 2))
  else
    Format.pp_print_string fmt s

let pp_item fmt {phrase; expect} =
  Format.fprintf fmt "Test: %a\nExpected result: %s" pp_phrase phrase expect

let pp =
  Format.pp_print_list
    ~pp_sep:(fun fmt () -> Format.fprintf fmt "\n")
    pp_item

(** {2 Parsing} *)

module Parsing = struct
  let get_at_offset (lexbuf: Lexing.lexbuf) offset =
    if offset >= lexbuf.lex_buffer_len - lexbuf.lex_curr_pos
    then None
    else Some (Bytes.get lexbuf.lex_buffer (lexbuf.lex_curr_pos + offset))

  (** FIXME: assumes no newlines
      FIXME: only works for string-based lexing buffers *)
  let skip (lexbuf: Lexing.lexbuf) offset =
    let offset = min offset (lexbuf.lex_buffer_len - lexbuf.lex_curr_pos) in
    lexbuf.lex_curr_pos <- lexbuf.lex_curr_pos + offset;
    if Lexing.with_positions lexbuf then
      lexbuf.lex_curr_p <- {
        lexbuf.lex_curr_p with pos_cnum = lexbuf.lex_curr_p.pos_cnum + offset
      }

  let skip_while (p: char -> bool) (lexbuf: Lexing.lexbuf) : unit =
    let offset = ref 0 in
    while Option.fold ~none:false ~some:p (get_at_offset lexbuf !offset) do
      incr offset
    done;
    skip lexbuf !offset

  let skip_spaces_and_tabs = skip_while (fun c -> c = ' ' || c = '\t')

  (** Find the next end of line ['\n'] character in the lexing buffer and set
      the position to the character just after.
      Return true if and only if end of line character has been found.

      FIXME: This only works when the lexing buffer has been built via the
      [Lexing.from_string] function. *)
  let find_next_eol (lexbuf: Lexing.lexbuf) =
    skip_while ((<>) '\n') lexbuf;
    match get_at_offset lexbuf 0 with
    | None -> false
    | Some c ->
      if c <> '\n' then panic "skip_while did not fulfil its contract";
      skip lexbuf 1;
      true

  let rec find_next_phrase (lexbuf: Lexing.lexbuf) =
    skip_spaces_and_tabs lexbuf;
    match get_at_offset lexbuf 0 with
    | None -> false
    | Some '#' -> true
    | Some _ -> find_next_eol lexbuf && find_next_phrase lexbuf

  let rec rev_parse items lexbuf =
    skip_spaces_and_tabs lexbuf;
    match get_at_offset lexbuf 0, get_at_offset lexbuf 1 with
    | Some '#', Some ' ' ->
      skip lexbuf 2;
      let phrase = !Toploop.parse_toplevel_phrase lexbuf in
      if find_next_eol lexbuf then (
        let expect_start = lexbuf.lex_curr_pos in
        let found_next_phrase = find_next_phrase lexbuf in
        let expect =
          Bytes.sub_string
            lexbuf.lex_buffer
            expect_start
            (lexbuf.lex_curr_pos - expect_start)
          |> String.trim
        in
        let items = {phrase; expect} :: items in
        if found_next_phrase
        then rev_parse items lexbuf
        else Ok items
      ) else
        Ok ({phrase; expect = ""} :: items)
    | _ -> Error.fail "parse error: expected `# ` at the start of next command"
end

let parse txt =
  let lexbuf = Lexing.from_string txt in
  let+ items = Parsing.rev_parse [] lexbuf in
  List.rev items

let run (doctests: t) =
  let buffer = Buffer.create 0 in
  let fmt = Format.formatter_of_buffer buffer in
  List.fold_left
    (fun state {phrase; expect} ->
      Buffer.clear buffer;
      let* () =
        try
          if Toploop.(execute_phrase true fmt phrase)
          then ok
          else fail "something went wrong"
        with exn ->
          Location.report_exception fmt exn;
          ok
      in
      let result =
        let got = Buffer.to_bytes buffer |> String.of_bytes |> String.trim in
        if not (ExtString.loose_equality got expect) then
          fail "The following test failed:\n  %a\nExpected:\n  %s\nGot:\n  %s"
            pp_phrase phrase expect got
        else
          ok
      in
      Result.fold
        ~ok:(fun () -> result)
        ~error:(fun err -> Result.map_error (Error.combine err) result)
        state)
    ok
    doctests
