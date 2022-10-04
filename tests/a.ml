(** This is a random ocamldoc comment *)
let toto = 0

(** Try to find the answer to the ultimate question of life, the universe and
    everything.

    Example:

    {[
      # A.ultimate_answer () ;;
      - : int = 42
    ]}
*)
let ultimate_answer () = 42

(** Double its argument. 

    Examples:

    {[
      # A.double 1 ;;
      - : int = 2
    ]}

    {[
      # A.double 21 ;;
      - : int = 42
    ]}

    Note that the double of zero is zero:

    {[
      # A.double 0 = 0 ;;
      - : bool = true
    ]}
*)
let double x =
  x * 2
