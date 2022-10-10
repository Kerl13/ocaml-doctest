(** This is an interface file containing doctests *)

(** This is a multi line test

    {@doctest [
      # let open Testlib.B in
        let x = 21 in
        let one = 1 in
        multiply x (add one one);;
      - : int = 42
    ]}
*)
val add: int -> int -> int

(** This is a doctest with multiple statements

    {@doctest [
      # open Testlib.B ;;
      # let x = 21 ;;
      val x : int = 21
      # multiply x 2 ;;
      - : int = 42
      # let y =
        multiply x (* Look! Comments
          spanning multiple lines work! *) 2 
        (* That is because we reuse OCaml's top level parser *)
        ;;
      val y : int = 42
    ]}
 *)
val multiply: int -> int -> int
