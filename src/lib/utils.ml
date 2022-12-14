(** {1 Curated list of stuff we always want in the scope} *)

(** {2 Monadic operators and helpers for Result} *)

let (let*) = Result.bind
let (let+) x f = Result.map f x

let (>>=) = Result.bind
let (<$>) = Result.map

let ok = Ok ()

(** {2 Error handling} *)

let panic args =
  Format.kasprintf
    (fun msg ->
      Format.eprintf "[PANIC] %s@." msg;
      exit 2)
    args

let fail args =
  Format.kasprintf Result.error args
