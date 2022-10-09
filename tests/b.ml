(** This is a multi line test

    {@doctest [
      # let open Testlib.B in
        let x = 21 in
        let one = 1 in
        multiply x (add one one);;
      - : int = 42
    ]}
*)

let add x y = x + y

(** This is a doctest with multiple statements

    {@doctest [
      # open Testlib.B ;;
      # let x = 21 ;;
      val x : int = 21
      # multiply x 2 ;;
      - : int = 42
    ]}
 *)
let multiply x y = x * y
