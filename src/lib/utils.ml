(** {1 Curated list of stuff we always want in the scope} *)

(** {2 Monadic operators and helpers for Result} *)

let (let*) = Result.bind
let (let+) x f = Result.map f x

let (>>=) = Result.bind
let (<$>) = Result.map

let ok = Ok ()
let fail = Error.fail

(** {2 Panicking} *)

let panic args =
  Format.kasprintf (Format.eprintf "[PANIC] %s@.") args
