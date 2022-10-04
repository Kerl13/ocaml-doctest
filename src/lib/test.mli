(** {1 Doctests} *)

type t
(** Type type of doctests *)

val parse: string -> (t, Error.t) Result.t
(** Parse a string as a doctest. The string should look like a toplevel session,
  like:
  {[
    # let f x = x in f 0 ;;
    - : int = 0
  ]}
  *)

val run: t -> (unit, Error.t) Result.t

(** {2 Pretty printing} *)

val pp: Format.formatter -> t -> unit
(** Pretty print the doctest *)
