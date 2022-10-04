(** {1 Documetation comments} *)

type t
(** The type of documentation comments. *)

val location: t -> Location.t

val parse: Location.t -> string -> t
(** Take the location of the comment in a file, the string of the comment and
  parse the comment. *)

val collect_doctests: t -> (Test.t, Error.t) Result.t list
(** Collect all the doctests in the documentation comment.
  Return a list of {!Result.t} since any doctest might be ill-formed. *)
