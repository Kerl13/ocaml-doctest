(** My awesome library *)

(** This is a random ocamldoc comment without doctest.

    Let me introduce the zero constant. *)
let zero = 0

(** This function tries to find the answer to the ultimate question of life, the
    universe and everything. Unfortunately, I don't know what to do with the
    result :(

    Example:

    {@doctest [
      # Testlib.A.ultimate_answer () ;;
      - : int = 42
    ]}
*)
let ultimate_answer () = 42

(** [double] doubles its argument.

    Examples:

    {@doctest [
      # Testlib.A.double 1 ;;
      - : int = 2
    ]}

    {@doctest [
      # Testlib.A.double 21 ;;
      - : int = 42
    ]}

    Special case: note that the double of zero is zero:

    {@doctest [
      # Testlib.A.double 0 = 0 ;;
      - : bool = true
    ]}

    Be aware that [double] only works for ints because *type systems*.
    (Okay, this is just a pretext to test exception handling in doctest.)

    {@doctest [
      # Testlib.A.double 0.5 ;;
      Error: This expression has type float
             but an expression was expected of type int
    ]}

    By the way, you can call functions from other modules to check that [double]
    behaves correctly:

    {@doctest [
      # Testlib.A.double 4 = Testlib.B.multiply 2 4 ;;
      - : bool = true
    ]}

    {@doctest [
      # Testlib.A.double 4 = Testlib.B.add 4 4 ;;
      - : bool = true
    ]}
*)
let double x =
  x * 2

(** Let us add a failing test now.

    This the the [abs] function, it always returns a non negative value… Right?

    {@doctest [
      # Testlib.A.abs min_int > 0 ;;
      - : bool = true
    ]}
*)
let abs x =
  if x < 0 then
    - x
  else
    x
