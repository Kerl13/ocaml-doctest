(** Let us add a failing test now.

    This the the [abs] function, it always returns a non negative value… Right?

    {@doctest [
      # open Testlib.Negative ;;
      # abs min_int > 0 ;;
      - : bool = true
    ]}
*)
let abs x =
  if x < 0 then - x else x
