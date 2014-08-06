all: interpreter print_ast

interpreter:
	ocamlbuild interpreter.native

print_ast:
	ocamlbuild print_ast.native

test: interpreter
	./test.py

clean:
	ocamlbuild -clean
