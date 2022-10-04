# OCaml doctest

**DISCLAIMER: this is just an experiment => don't expect it to work**

## What's that?

Take a look at `tests/a.ml` and then run `dune runtest`.

It should display something like:
```
[ERROR] The following test failed:  
  A.abs min_int > 0 ;;
Expected:
  - : bool = true
Got:
  - : bool = false


At File "tests/a.ml", lines 54-62, characters 0-2: 0 / 1 doctests passed
At File "tests/a.ml", lines 21-50, characters 0-2: 4 / 4 doctests passed
At File "tests/a.ml", lines 8-18, characters 0-2: 1 / 1 doctests passed
```
