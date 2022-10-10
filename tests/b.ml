let add x y = x + y

(** This ocamldoc comment is not part of the interface file [b.mli]. It won't
    appear in the documentation but can nevertheless contain doctests.

    This can be used to add extra tests that don't deserve to be part of the
    official documentation of your package but can be useful to maintainers
    and/or increase test coverage.

    {@doctest [
      # open Testlib.B ;;
      # let x = 37 in
        multiply 4 x = add (add x x) (add x x) ;;
      - : bool = true
    ]}
*)
let multiply x y = x * y
