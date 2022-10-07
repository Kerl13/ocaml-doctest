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

let multiply x y = x * y
