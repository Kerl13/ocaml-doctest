type t

val fail: ('a, Format.formatter, unit, ('b, t) result) format4 -> 'a

val pp: Format.formatter -> t -> unit
