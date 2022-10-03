type t = {
  phrase: string;
  expected_result: string
}

let pp fmt doctest =
  Format.fprintf fmt "# %s\n%s" doctest.phrase doctest.expected_result

let search_end_of_cmd s =
  let rec search i =
    if i >= String.length s - 2 then
      None
    else
      if s.[i] = ';' then
        if s.[i + 1] = ';' then (
          assert (s.[i + 2] = '\n');
          Some i
        ) else search (i + 2)
      else
        search (i + 1)
  in
  search 0

let parse (s: string) : (t, string) Result.t =
  match search_end_of_cmd s with
  | Some i -> Ok {
      phrase = String.sub s 2 i;
      expected_result = String.sub s (i + 3) (String.length s - i - 3)
    }
  | None -> Error ("Could not parse: " ^ s)

module Collect = struct
  let from_comment: _ list -> Odoc_parser.Ast.t -> _ list =
    let module Ast = Odoc_parser.Ast in
    let module Loc = Odoc_parser.Loc in

    let collect_code_block tests options content =
      ignore options;
      parse content.Loc.value :: tests
    in

    let collect_block (tests: _ list) : Ast.block_element -> _ list = function
      | `Paragraph _ -> tests
      | `Code_block (options, content) -> collect_code_block tests options content
      | `Verbatim _ -> tests
      | `Modules _ -> tests
      | `List _ -> tests
      | `Tag _ -> tests
      | `Heading _ -> tests
    in

    List.fold_left
      (fun tests wl -> collect_block tests wl.Loc.value )

    let from_file (filename: string) : (t, string) Result.t list =
      let cmt = Cmt_format.read_cmt filename in
      List.fold_left
        (fun doctests (s, loc) ->
          if s.[0] = '*' then (
            Format.eprintf "[DEBUG] Found ocamldoc comments at %a\n"
              Location.print_loc loc;
            let location = {
                loc.loc_start with pos_cnum = loc.loc_start.pos_cnum + 3
            } in
            let p = Odoc_parser.parse_comment ~location ~text:s in
            let ast = Odoc_parser.ast p in
            from_comment doctests ast
          ) else doctests)
        []
        cmt.cmt_comments
end

let run doctest =
  let buffer = Buffer.create 0 in
  let fmt = Format.formatter_of_buffer buffer in
  let ok =
    Lexing.from_string doctest.phrase
    |> !Toploop.parse_toplevel_phrase
    |> Toploop.execute_phrase true fmt
  in
  assert ok;
  let result =
    Buffer.to_bytes buffer
    |> String.of_bytes
    |> String.trim
  in
  if result <> doctest.expected_result then
    Format.eprintf "[DEBUG] ERROR:\n`%s`\n<>\n`%s`\n"
      result doctest.expected_result
  else
    Format.eprintf "[DEBUG] SUCCESS\n"
