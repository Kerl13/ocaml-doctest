open Utils

type t = {
  filename: string;
  comments: Comment.t list
}
(* We only care about comments. *)

(** {2 File operations} *)

let check_filename (filename: string) =
  match Filename.extension filename with
  | ".cmt" | ".cmti" ->
    if Sys.file_exists filename
    then Ok filename
    else fail "File `%s' does not exist" filename
  | _ -> fail "File.of_filename: a .cmt file is expected"

let parse filename =
  let* filename = check_filename filename in
  let+ cmt =
    try Ok (Cmt_format.read_cmt filename)
    with Symtable.Error error -> fail "%a" Symtable.report_error error
  in
  let comments =
    List.fold_left
      (fun comments (txt, loc) ->
        (* only keep documentation comments *)
        if String.length txt > 0 && txt.[0] = '*'
        then Comment.parse loc txt :: comments
        else comments)
      []
      cmt.cmt_comments
  in {filename; comments}

(** {2 Pretty printing} *)

let pp fmt file =
  Format.fprintf fmt "Doctestable file `%s'" file.filename
