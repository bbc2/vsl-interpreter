type arg =
  | ArgVar of string
  | ArgArray of string

type ret_type =
  | VoidFun
  | IntFun

type decl =
  | DeclVar of string
  | DeclArray of string * int

type ref =
  | Var of string
  | Array of string * expr

and expr =
  | Int of int
  | Ref of ref
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr
  | IntCall of string * expr list

type printable =
  | Str of string
  | Expr of expr

type inst =
  | Return of expr
  | VoidCall of string * expr list
  | Assign of ref * expr
  | Print of printable list
  | Read of ref list
  | If of expr * inst * inst option
  | While of expr * inst
  | Block of decl list * inst list

type part =
  | Fun of ret_type * string * arg list * inst
  | Proto of ret_type * string * arg list

type prog = part list

