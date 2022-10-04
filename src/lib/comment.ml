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

  let rec collect tests (block: Ast.nestable_block_element Loc.with_location) =
    match block.value with
    | `Code_block (Some (lang, _), content) when lang.value = "doctest" ->
      Test.parse content.value :: tests
    | `List (_, _, elts) -> collect_listlist tests elts
    | _ -> tests
  and collect_listlist tests =
    (* Why is this a list of lists? *)
      List.fold_left (List.fold_left collect) tests
  in

  fun comment ->
    List.fold_left
      (* Very frustrating code duplication here... *)
      (fun tests (block: Ast.block_element Loc.with_location) ->
        match block.Loc.value with
        | `List (_, _, elts) -> collect_listlist tests elts
        | `Code_block (Some (lang, _), content) when lang.value = "doctest" ->
          Test.parse content.value :: tests
        | _ -> tests)
      []
      comment.ast
