(** {1 Testable files} *)

type t
(** The type of doctestable files. *)

(** {2 File operations} *)

val of_filename: string -> (t, string) result
(** Check that a file name corresponds to a valid testable file and convert it
  to {!t}. *)

val collect_doc_comments: t -> Comment.t list
(** Collect the documentation comments in the file. *)

(** {2 Pretty printing} *)

val pp: Format.formatter -> t -> unit
(** Pretty print the file. *)
