%{
(* Here can come OCaml code *)
%}

%token Func Proto IntType VoidType
%token Print Read Return Assign
%token If Then Else Fi While Do Done
%token Comma LeftPar RightPar LeftCurly RightCurly LeftSquare RightSquare
%token Plus Minus Times Divide
%token <int> Int
%token <string> Id
%token <string> Str
%token Eof

%start <Ast.prog> prog

%left Plus Minus
%left Times Divide

%%

prog:
| p = part+ Eof { p }

part:
| Func r = ret_type name = Id LeftPar args = separated_list(Comma, arg) RightPar
  body = inst { Ast.Fun (r, name, args, body) }
| Proto r = ret_type name = Id LeftPar args = separated_list(Comma, arg) RightPar { Ast.Proto (r, name, args) }

ret_type:
| VoidType { Ast.VoidFun }
| IntType { Ast.IntFun }

arg:
| i = Id { Ast.ArgVar i }
| a = Id LeftSquare RightSquare { Ast.ArgArray a }

inst:
| Return e = expr { Ast.Return e }
| name = Id LeftPar args = separated_list(Comma, expr) RightPar { Ast.VoidCall (name, args) }
| r = ref Assign e = expr { Ast.Assign (r, e) }
| Print l = separated_nonempty_list(Comma, printable) { Ast.Print l }
| Read refs = separated_nonempty_list(Comma, ref) { Ast.Read refs }
| If cond = expr Then then_branch = inst Fi { Ast.If (cond, then_branch, None) }
| If cond = expr Then then_branch = inst
  Else else_branch = inst Fi { Ast.If (cond, then_branch, Some else_branch) }
| While cond = expr Do body = inst Done { Ast.While (cond, body) }
| LeftCurly d = decls* i = inst+ RightCurly { Ast.Block (List.concat(d), i) }

expr:
| n = Int { Ast.Int n }
| r = ref { Ast.Ref r }
| name = Id LeftPar args = separated_list(Comma, expr) RightPar { Ast.IntCall (name, args) }
| e = expr Plus f = expr { Ast.Add (e, f) }
| e = expr Minus f = expr { Ast.Sub (e, f) }
| e = expr Times f = expr { Ast.Mul (e, f) }
| e = expr Divide f = expr { Ast.Div (e, f) }
| LeftPar e = expr RightPar { e }

ref:
| name = Id { Ast.Var name }
| name = Id LeftSquare index = expr RightSquare { Ast.Array (name, index) }

printable:
| s = Str { Ast.Str s }
| e = expr { Ast.Expr e }

decls:
| IntType d = separated_nonempty_list(Comma, decl) { d }

decl:
| name = Id { Ast.DeclVar name }
| name = Id LeftSquare size = Int RightSquare { Ast.DeclArray (name, size) }
