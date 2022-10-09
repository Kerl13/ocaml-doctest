(** Very naive function to find the occurrence of a substring in a string.
    You should use a better algorithm for big [u], but in my use case
    [u] has length 2 so that will do. *)
let index_from_substring (s: string) (i: int) (u: string) =
  let len_s = String.length s and len_u = String.length u in
  if i >= len_s then invalid_arg "ExtString.index_from_subword";
  if len_u = 0 then
    Some i
  else
    let rec search i =
      match String.index_from_opt s i u.[0] with
      | Some i as loc ->
        if len_u > len_s - i then None
        else if String.sub s i len_u = u then loc
        else search (i + 1)
      | None -> None
    in
    search i

let is_whitespace = function
  | ' ' | '\n' | '\t' | '\r' -> true
  | _ -> false

let rec skip_whitespaces s i =
  if i < String.length s && is_whitespace s.[i]
  then skip_whitespaces s (i + 1)
  else i

let loose_equality s1 s2 =
  let len1 = String.length s1 and len2 = String.length s2 in

  (* Ugliest thing ever *)
  let rec equal i j =
    if i = len1 then
      skip_whitespaces s2 j = len2
    else if j = len2 then
      skip_whitespaces s1 i = len1
    else if s1.[i] = s2.[j] then
      equal (i + 1) (j + 1)
    else if is_whitespace s1.[i] || is_whitespace s2.[j] then
      equal (skip_whitespaces s1 i) (skip_whitespaces s2 j)
    else false
  in
  equal 0 0
