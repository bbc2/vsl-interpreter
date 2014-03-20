type prog = part list

and part =
  | Fun of ret_type * string * arg list * inst
  | Proto of ret_type * string * arg list

and ret_type =
  | VoidFun
  | IntFun

and arg =
  | ArgVar of string
  | ArgArray of string

and inst =
  | Return of expr
  | VoidCall of string * expr list
  | Assign of ref * expr
  | Print of printable list
  | Read of ref list
  | If of expr * inst * inst option
  | While of expr * inst
  | Block of decl list * inst list

and expr =
  | Int of int
  | Ref of ref
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr
  | IntCall of string * expr list

and ref =
  | Var of string
  | Array of string * expr

and printable =
  | Str of string
  | Expr of expr

and decl =
  | DeclVar of string
  | DeclArray of string * int


