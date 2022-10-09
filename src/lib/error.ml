type t = string

let combine e1 e2 = e1 ^ "\n" ^ e2

let fail args =
  Format.kasprintf Result.error args

let pp = Format.pp_print_string
