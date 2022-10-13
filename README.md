# OCaml doctest

`ocaml-doctest` allows you write executable examples in your documentation,
that look like an interactive toplevel session, and to automatically run them to
check that they behave as advertised.
If you are familiar with it, this is similar to the [Python's
doctest](https://docs.python.org/3/library/doctest.html).
This has the advantage that your documentation will always be up to date with
your implementation.

As an example, here is a simple module with some "doctestable" documentation
code blocks:

```ocaml
(** {1 This is example.ml} *)

(** Compute the factorial of an interger

    The factorial of a non-negative integer n is the product [1 * 2 * ... * n].

    The first factorials are:
    {@doctest [
      # open Example ;;
      # List.init 7 factorial ;;
      - : int list = [1; 1; 2; 6; 24; 120; 720]
    ]}

    The [factorial] function raises [Invalid_argument] on negative numbers:
    {@doctest [
      # open Example ;;
      # factorial (-1) ;;
      Exception: Invalid_argument "factorial".
      # factorial (-2) ;;
      Exception: Invalid_argument "factorial".
    ]}

    The factorial function is pretty useless with regular (bounded) integers.
    Here is a test that fails:
    {@doctest [
      # open Example ;;
      # factorial 30 ;;
      - : int = 265252859812191058636308480000000
    ]}
*)
let factorial =
  let rec f acc n =
    if n <= 1 then acc else f (acc * n) (n - 1)
  in
  fun n ->
    if n < 0 then invalid_arg "factorial";
    f 1 n
```

Note the `@doctest` tag at the beginning of the formatted code blocks delimited
by `{[ ... ]}`. `ocaml-doctest` reads these code blocks and feeds their
instructions (delimited by `# ... ;;`) to the ocaml toplevel to check their
output against what is specified in the documentation.

This is achieved by first compiling your module with `-bin-annot` and passing
the produced `.cmt` (and `.cmti` if you have a `.mli`) files to the `doctest`
like so:

```sh
$ ocamlc -c -bin-annot example.ml
$ doctest -l example.cmo example.cmt
```

Note that we also pass `-l example.cmo` as an option. This is because the
toplevel needs to know our `Example` module to be able to run the tests. This
tells `doctest` to issue a `#use "example.cmo"` directive in the toplevel.

The output of the last command should look like this:
```
[ERROR] File "example.ml", lines 24-28, characters 4-6:
The following test failed:
  factorial 30
Expected:
  - : int = 265252859812191058636308480000000
Got:
  - : int = 458793068007522304
[INFO] File "example.ml", lines 3-29, characters 0-2: 2 / 3 tests passed
[INFO] Total: 2 / 3 tests passed
```

## Disclaimer

`ocaml-doctest` is at a very early stage of development, so expect bugs and API
changes. Any feedback is welcome though, so don't hesitate to contact me, fill
an issue, or send PRs / patches.

## Dune integration

The major quirk (and thus most urgent issue) is that it is very impractical to
integrate `ocaml-doctest` with dune at the moment.

Basically, you have to add a rule in your dune file which looks like this:
```dune
(rule
 (alias runtest)
 (action
  (run doctest
    -d .your_package.objs/byte
    -l %{lib:first_dependency:first_dep.cma}
    -l %{lib:second_dependency:second_dep.cma}
    ...
    -l %{cma:testlib}
   .your_package.objs/byte/your_package__SomeModule.cmt
   .your_package.objs/byte/your_package__SomeOtherModule.cmt
   .your_package.objs/byte/your_package__SomeModuleWithAnInterface.cmti)))
```
You will find examples of this in the `tests/dune` and `src/lib/dune` files in
the repository.
The list of `-l %{lib:foo:bar.cma}` options you have to add for your specific
project can be given by `dune ocaml top | grep '^#load'`, though I have had
issues with it not being sufficient.
If you have any suggestion to make this better, please tell me! ^^

## Licence

Copyright (C) 2022 Martin Pépin

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see <https://www.gnu.org/licenses/>.
