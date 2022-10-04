type t = {
  loc: Location.t;
  ast: Odoc_parser.Ast.t;
}

let location comment = comment.loc

let parse (loc: Location.t) text =
  (* shift 2 characters to skip the opening comment token *)
  let lexing_position = {
    loc.loc_start with pos_cnum = loc.loc_start.pos_cnum + 2
  } in
  let ast =
    Odoc_parser.parse_comment ~location:lexing_position ~text
    |> Odoc_parser.ast
  in
  {loc; ast}

let collect_doctests: t -> _ list =
  let module Ast = Odoc_parser.Ast in
  let module Loc = Odoc_parser.Loc in

  let collect_code_block tests options content =
    ignore options;
    Test.parse content.Loc.value :: tests
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

  fun comment ->
    List.fold_left
      (fun tests wl -> collect_block tests wl.Loc.value)
      []
      comment.ast
