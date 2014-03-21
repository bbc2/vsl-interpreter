open Ast
let printf = Printf.printf

module SMap = Map.Make(String)

type context = { env : (Type.value SMap.t) list ; ret : int option }

let rec index_funs prog funs = match prog with
  | [] -> funs
  | Proto (ret_type, proto_name, args)::td -> index_funs td funs
  | Fun (ret_type, name, args, body)::td ->
    index_funs td (SMap.add name (ret_type, args, body) funs)

let rec feval funs ctx name args =
  let (t, a, i) = SMap.find name funs in
  let string_of_arg a = match a with
    | ArgVar arg -> arg
    | ArgArray arg -> arg in
  let ctx = ieval funs { env = Env.bind (List.combine (List.map string_of_arg a) args)
                             (Env.push ctx.env);
                         ret = ctx.ret } i in
  { ctx with env = Env.pop ctx.env }

and ieval funs ctx i = match i with
  | Return e -> { env = ctx.env ; ret = Some (eeval funs ctx.env e) }
  | VoidCall (name, args) ->
    let argeval funs env a = match a with
      | Ref (Var v) -> Env.find v env
      | _ -> Type.Int (eeval funs env a) in
    let new_ctx = feval funs ctx name
        (List.map (argeval funs ctx.env) args) in
    begin
      match new_ctx.ret with
      | Some n -> failwith "Function returning something"
      | None -> new_ctx
    end
  | Assign (Var v, e) -> { env = Env.update v (Type.Int (eeval funs ctx.env e)) ctx.env;
                           ret = None }
  | Assign (Array (a, ei), ev) ->
    let ia = Type.get_intarray (Env.find a ctx.env) in
    ia.(eeval funs ctx.env ei) <- eeval funs ctx.env ev; ctx
  | Block (decls, insts) ->
    let rec declare decls env = match decls with
      | [] -> env
      | (DeclVar v)::tl -> declare tl (Env.add v (Type.Int 0) env)
      | (DeclArray (a, size))::tl -> declare tl (Env.add a (Type.IntArray (Array.make size 0)) env) in
    let rec execute insts ctx = match insts with
      | [] -> ctx
      | i::tl ->
        let new_ctx = ieval funs ctx i in
        match new_ctx.ret with
        | Some _ -> new_ctx
        | None -> execute tl new_ctx in
    let final_ctx = execute insts { ctx with env = (declare decls (Env.push ctx.env)) } in
    { final_ctx with env = Env.pop final_ctx.env }
  | Print printables ->
    let rec print printables =
      match printables with
      | [] -> ()
      | (Str s)::tl -> print_string (Scanf.unescaped s); print tl
      | (Expr e)::tl -> print_int (eeval funs ctx.env e); print tl in
    print printables; ctx
  | Read refs ->
    let rec read env refs =
      match refs with
      | [] -> env
      | (Var v)::tl -> read (Env.update v (Type.Int (read_int ())) env) tl
      | (Array (a, ei))::tl ->
        let ia = Type.get_intarray (Env.find a ctx.env) in
        ia.(eeval funs ctx.env ei) <- read_int ();
        read env tl in
    { ctx with env = read ctx.env refs }
  | If (cond, i_then, maybe_i_else) ->
    if (eeval funs ctx.env cond) = 0 then
      match maybe_i_else with
      | None -> ctx
      | Some i_else -> ieval funs ctx i_else
    else
      ieval funs ctx i_then
  | While (cond, body) ->
    let rec loop ctx =
      match ctx.ret with
      | Some _ -> ctx
      | None ->
        if (eeval funs ctx.env cond) = 0 then
          ctx
        else
          loop (ieval funs ctx body) in
    loop ctx

and eeval funs env e = match e with
  | Int i -> i
  | Ref (Var v) -> Type.get_int (Env.find v env)
  | Ref (Array (a, e)) ->
    let ia = Type.get_intarray (Env.find a env) in
    ia.(eeval funs env e)
  | Add (a, b) -> (eeval funs env a) + (eeval funs env b)
  | Sub (a, b) -> (eeval funs env a) - (eeval funs env b)
  | Mul (a, b) -> (eeval funs env a) * (eeval funs env b)
  | Div (a, b) -> (eeval funs env a) / (eeval funs env b)
  | IntCall (name, args) ->
    let argeval funs env a = match a with
      | Ref (Var v) -> Env.find v env
      | _ -> Type.Int (eeval funs env a) in
    let ctx = feval funs { env = env ; ret = None } name
        (List.map (argeval funs env) args) in
    begin
      match ctx.ret with
      | Some n -> n
      | None -> failwith "Function not returning anything"
    end

let _ =
  let funs = index_funs (Parser.prog Lexer.lexer
                           (Lexing.from_channel
                              (open_in Sys.argv.(1)))) SMap.empty in
  feval funs { env = Env.empty; ret = None } "main" []
