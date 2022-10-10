(** {1 Doctests} *)

type t
(** Type type of doctests *)

val parse: string -> (t, Error.t) Result.t
(** Parse a string as a doctest. The string should look like a toplevel session,
    like the content of this block of code:

    {[
      # let x = 2 + 2 ;;
      val x : int = 4
    ]}

    For instance:

    {@doctest [
      # List.length [1; 2; 3];;
      - : int = 3
    ]}

    {@doctest [
      # open Doctest ;;
      # let test = Test.parse "let x = 2 + 2 ;;\nval x : int = 4" in
      Result.is_ok test ;;
      - : bool = true
      # let woops = Test.parse "let s = \"I forgot the double semicolon\"" in
      Result.is_ok woops ;;
      - : bool = false
    ]}
*)

val run: t -> (unit, Error.t) Result.t

(** {2 Pretty printing} *)

val pp: Format.formatter -> t -> unit
(** Pretty print the doctest *)
