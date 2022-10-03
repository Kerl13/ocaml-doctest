(lang dune 3.3)

(name doctest)

(generate_opam_files true)

(authors "Martin Pépin <kerl@wkerl.me>")

(maintainers "Martin Pépin <kerl@wkerl.me>")

(package
 (name doctest)
 (synopsis "doctesting ocaml modules")
 (depends
  (ocaml :build)
  (dune :build)
  compiler-libs
  odoc-parser))
