type t = string

let fail args =
  Format.kasprintf Result.error args

let pp = Format.pp_print_string
