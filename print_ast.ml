open Ast
let printf = Printf.printf

let print_spaces n =
  print_string (String.make (2 * n) ' ')

let rec print_prog prog depth =
  print_spaces depth; printf "Prog\n";
  print_parts prog depth;

and print_parts parts depth =
  let d = depth + 1 in match parts with
  | [] -> ()
  | hd::tl -> print_part hd d; print_parts tl depth

and print_part part depth =
  print_spaces depth;
  let d = depth + 1 in match part with
  | Fun (ret_t, name, args, body) -> printf "Fun\n"; print_ret_type ret_t d;
    print_spaces d; printf "%s\n" name;
    print_spaces d; printf "Args\n"; print_args args (d + 1);
    print_spaces d; printf "Body\n"; print_inst body (d + 1)
  | Proto (ret_t, name, args) -> printf "Proto\n"; print_ret_type ret_t d;
    print_spaces d; printf "%s\n" name;
    print_spaces d; printf "Args\n"; print_args args (d + 1)

and print_ret_type ret_t depth =
  print_spaces depth;
  match ret_t with
  | VoidFun -> printf "Void\n"
  | IntFun -> printf "Int\n"

and print_args args depth =
  match args with
  | [] -> ()
  | hd::tl -> print_arg hd depth; print_args tl depth

and print_arg arg depth =
  print_spaces depth;
  match arg with
  | ArgVar name -> printf "ArgVar %s\n" name;
  | ArgArray name -> printf "ArgArray %s\n" name;

and print_inst inst depth =
  print_spaces depth;
  let d = depth + 1 in match inst with
  | Return e -> printf "Return\n"; print_expr e d
  | VoidCall (name, args) -> printf "VoidCall %s\n" name; print_exprs args d
  | Assign (ref, e) -> printf "Assign\n"; print_ref ref d; print_expr e d
  | Print p -> printf "Print\n"; print_printables p d
  | Read refs -> printf "Read\n"; print_refs refs d
  | If (cond, then_branch, else_branch) -> printf "If\n"; print_expr cond d;
    print_inst then_branch d;
    begin match else_branch with
      | None -> ()
      | Some i -> print_inst i d end
  | While (cond, body) -> printf "While\n"; print_expr cond d; print_inst body d;
  | Block (decls, insts) -> printf "Block\n";
    print_spaces d; printf "Decls\n"; print_decls decls (d + 1);
    print_spaces d; printf "Insts\n"; print_insts insts (d + 1)

and print_insts insts depth =
  match insts with
  | [] -> ()
  | hd::tl -> print_inst hd depth; print_insts tl depth

and print_decl decl depth =
  print_spaces depth;
  match decl with
  | DeclVar name -> printf "DeclVar %s\n" name
  | DeclArray (name, size) -> printf "DeclArray %s %d\n" name size

and print_decls decls depth =
  match decls with
  | [] -> ()
  | hd::tl -> print_decl hd depth; print_decls tl depth

and print_expr expr depth =
  print_spaces depth;
  let d = depth + 1 in match expr with
  | Int n -> printf "Int %d\n" n
  | Ref ref -> printf "Ref\n"; print_ref ref d
  | Add (e, f) -> printf "Add\n"; print_expr e d; print_expr f d
  | Sub (e, f) -> printf "Sub\n"; print_expr e d; print_expr f d
  | Mul (e, f) -> printf "Mul\n"; print_expr e d; print_expr f d
  | Div (e, f) -> printf "Div\n"; print_expr e d; print_expr f d
  | IntCall (name, args) -> printf "IntCall %s\n" name; print_exprs args d

and print_exprs exprs depth =
  match exprs with
  | [] -> ()
  | hd::tl -> print_expr hd depth; print_exprs tl depth

and print_ref ref depth =
  print_spaces depth;
  let d = depth + 1 in match ref with
  | Var name -> printf "Var %s\n" name
  | Array (name, index) -> printf "Array %s\n" name; print_expr index d

and print_refs refs depth =
  match refs with
  | [] -> ()
  | hd::tl -> print_ref hd depth; print_refs tl depth

and print_printables p depth =
  match p with
  | [] -> ()
  | (Str s)::tl -> print_spaces depth; printf "\"%s\"\n" s; print_printables tl depth
  | (Expr e)::tl -> print_expr e depth; print_printables tl depth

let () =
  print_prog (Parser.prog Lexer.lexer (Lexing.from_channel (open_in Sys.argv.(1)))) 0
