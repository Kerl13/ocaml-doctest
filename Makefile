build:
	dune build @install

test:
	ocamlc -c -bin-annot tests/a.ml
	dune exec src/bin/doctest.exe tests/a.cmt

clean:
	dune clean
	rm -f tests/*.cmi tests/*.cmo tests/*.cmt
