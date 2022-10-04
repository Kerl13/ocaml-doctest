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

let run doctest =
  let buffer = Buffer.create 0 in
  let fmt = Format.formatter_of_buffer buffer in
  let test_run =
    try
      if (
        Lexing.from_string doctest.phrase
        |> !Toploop.parse_toplevel_phrase
        |> Toploop.execute_phrase true fmt
      ) then Ok ()
      else Error.fail "something went wrong"
    with Env.Error error ->
      Error.fail "%a" Env.report_error error
  in
  test_run >>= (fun () ->
    let got = Buffer.to_bytes buffer |> String.of_bytes |> String.trim in
    if got <> doctest.expect then
      Error.fail "Expected:\n  `%s`\nGot:\n  `%s`\n" doctest.expect got
    else
      Ok ())

(** {2 Pretty printing} *)

let pp fmt doctest =
  Format.fprintf fmt "# %s\n%s" doctest.phrase doctest.expect
