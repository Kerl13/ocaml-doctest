build:
	dune build

test:
	dune exec src/bin/doctest.exe _build/default/tests/.a.objs/byte/a.cmt

clean:
	dune clean
