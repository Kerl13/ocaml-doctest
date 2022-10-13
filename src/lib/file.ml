type t = string

(** {2 File operations} *)

let of_filename (filename: string) =
  match Filename.extension filename with
  | ".cmt" | ".cmti" ->
    if Sys.file_exists filename
    then Ok filename
    else Utils.fail "File `%s' does not exist" filename
  | _ -> Utils.fail "File.of_filename: a .cmt file is expected"

let collect_doc_comments file =
  let cmt = Cmt_format.read_cmt file in
  List.fold_left
    (fun comments (txt, loc) ->
      (* only keep documentation comments *)
      if String.length txt > 0 && txt.[0] = '*'
      then Comment.parse loc txt :: comments
      else comments)
    []
    cmt.cmt_comments

(** {2 Pretty printing} *)

let pp fmt =
  Format.fprintf fmt "Doctestable file `%s'"
