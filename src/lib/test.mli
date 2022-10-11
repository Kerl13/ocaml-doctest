(** {1 Doctests} *)

type t
(** Type type of doctests *)

val parse: string -> (t, string) Result.t
(** Parse a string as a doctest. The string should look like a toplevel session,
    like the content of this block of code:

    {v
{@doctest [
  # let x = 2 + 2 ;;
  val x : int = 4
]}
    v}

    More eloquently, the string should contain a succession of instructions
    started by a ['#'] at the start of a line and ended by a double semicolon
    [";;"] (possibly spanning several lines.
    Each such instruction is followed by an optionnal expected output reflecting
    what the ocaml toplevel would print given the instruction.
    In particular, [open] statements don't print anything.

    For instance:

    {@doctest [
      # open Doctest ;;
      # let test = Test.parse "# let x = 2 + 2 ;;\nval x : int = 4" ;;
      val test : (Doctest.Test.t, string) Result.t = Result.Ok <abstr>
      # let woops = Test.parse "# let s = \"I forgot the double semicolon\"" ;;
      val woops : (Doctest.Test.t, string) Result.t = Result.Error "Error: Syntax error\n"
      # let open_ = Test.parse "# open List ;;" ;;
      val open_ : (Doctest.Test.t, string) Result.t = Result.Ok <abstr>
    ]}
*)

val run: t -> (unit, string) Result.t
(** Feed the commands contained in a doctest to the ocaml toplevel and compare
    the output with the expected output specified in the test.

    Examples:

    {@doctest [
      # open Doctest ;;
      # let test = Test.parse {|
          # let sum = List.fold_left Int.add 0 [1; 2; 3];;
          val sum : int = 6
        |};;
      val test : (Doctest.Test.t, string) Result.t = Result.Ok <abstr>
      # Test.run (Result.get_ok test);;
      - : (unit, string) Result.t = Result.Ok ()
      # let wrong_test = Result.get_ok (Test.parse {|
          # 2 + 2 ;;
          - : int = 5
        |}) ;;
      val wrong_test : Doctest.Test.t = <abstr>
      # Test.run wrong_test ;;
      - : (unit, string) Result.t =
      Result.Error
        "The following test failed:\n  2 + 2\nExpected:\n  - : int = 5\nGot:\n  - : int = 4"
      ]}

    Failing and crashing tests are handled similarly:

    {@doctest [
      # open Doctest ;;
      # (* Check that this indeed crashes *) ;;
      # let crashing_test = Result.get_ok (Test.parse {|
          # List.hd [] ;;
          Exception: Failure "hd".
        |}) in
        Test.run crashing_test ;;
      - : (unit, string) Result.t = Result.Ok ()
    ]}
*)

(** {2 Pretty printing} *)

val pp: Format.formatter -> t -> unit
(** Pretty print the doctest *)
