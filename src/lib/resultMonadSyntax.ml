(** {1 Monadic operators to work with Result.t} *)

let (let*) = Result.bind
let (let+) x f = Result.map f x

let (>>=) = Result.bind
let (<$>) = Result.map
