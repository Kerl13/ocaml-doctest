(lang dune 3.4)

(name doctest)
(version 0.1.0-alpha1)
(source (github Kerl13/ocaml-doctest))

(generate_opam_files true)

(license GPL-3.0-or-later)

(authors "Martin Pépin <kerl@wkerl.me>")
(maintainers "Martin Pépin <kerl@wkerl.me>")

(package
 (name doctest)
 (synopsis "Doctesting ocaml modules")
 (description "This package provides doc testing facilities for OCaml in the
  style of Python's doctest. It allow to write executable documentation in
  {@doctest [ ... ]} ocamldoc comments that can be checked for correctness.
  This gives the opportunity to kill two birds with one stone as part of your
  documentation becomes a test as well.")
 (depends
  (ocaml :build)
  (dune :build)
  odoc-parser))
