(** {1 Testable files} *)

type t = private {
  filename: string;
  comments: Comment.t list
}
(** The type of doctestable files. *)

(** {2 File operations} *)

val parse: string -> (t, string) result
(** Check that a file name corresponds to a valid testable file and parse it. *)

(** {2 Pretty printing} *)

val pp: Format.formatter -> t -> unit
(** Pretty print the file. *)
