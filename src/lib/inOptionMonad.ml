type 'a t = 'a option

let (let*) = Option.bind
let (let+) x f = Option.map f x

let pure x = Some x
