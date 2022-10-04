type t = {
  phrase: string;
  expect: string
}

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

let parse (s: string) : (t, Error.t) Result.t =
  match search_end_of_cmd s with
  | Some i -> Ok {
      phrase = String.sub s 2 i;
      expect = String.sub s (i + 3) (String.length s - i - 3)
    }
  | None -> Error.fail "Could not parse: %s" s

let (>>=) = Result.bind

let is_whitespace = function
  | ' ' | '\n' | '\t' | '\r' -> true
  | _ -> false

let rec fast_fwd i s =
  if i < String.length s && is_whitespace s.[i]
  then fast_fwd (i + 1) s
  else i

let lax_string_equal s1 s2 =
  let len1 = String.length s1 and len2 = String.length s2 in

  (* Ugliest thing ever *)
  let rec equal i j =
    if i = len1 then
      fast_fwd j s2 = len2
    else if j = len2 then
      fast_fwd i s1 = len1
    else if s1.[i] = s2.[j] then
      equal (i + 1) (j + 1)
    else if is_whitespace s1.[i] || is_whitespace s2.[j] then
      equal (fast_fwd i s1) (fast_fwd j s2)
    else false
  in
  equal 0 0

let run doctest =
  let buffer = Buffer.create 0 in
  let fmt = Format.formatter_of_buffer buffer in
  let test_run =
    let lexbuf = Lexing.from_string doctest.phrase in
    (* Location.report_printer := (fun () -> Location.terminfo_toplevel_printer lexbuf); *)
    try
      if Toploop.(execute_phrase true fmt (!parse_toplevel_phrase lexbuf))
      then Ok ()
      else Error.fail "something went wrong"
    with exn ->
      Location.report_exception fmt exn;
      Ok ()
  in
  test_run >>= (fun () ->
    let got = Buffer.to_bytes buffer |> String.of_bytes in
    if not (lax_string_equal got doctest.expect) then
      Error.fail "The following test failed:\n  %s\nExpected:\n  %s\nGot:\n  %s\n"
        doctest.phrase doctest.expect got
    else
      Ok ())

(** {2 Pretty printing} *)

let pp fmt doctest =
  Format.fprintf fmt "# %s\n%s" doctest.phrase doctest.expect
