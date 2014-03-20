{
  open Parser
  exception LexingError
}

let digits = ['0' - '9']
let alpha = ['a' - 'z' 'A' - 'Z']
let space = ['\n' '\r' '\t' ' ']
let printable = [' ' - '~']
let str_char = printable # ['"']

rule lexer = parse
  | "//" [^'\n']* '\n'? { lexer lexbuf }
  | eof { Eof }
  | space+ { lexer lexbuf }
  | "FUNC" { Func }
  | "PROTO" { Proto }
  | "INT" { IntType }
  | "VOID" { VoidType }
  | "PRINT" { Print }
  | "READ" { Read }
  | "RETURN" { Return }
  | ":=" { Assign }
  | "IF" { If }
  | "THEN" { Then }
  | "ELSE" { Else }
  | "FI" { Fi }
  | "WHILE" { While }
  | "DO" { Do }
  | "DONE" { Done }
  | "," { Comma }
  | "(" { LeftPar }
  | ")" { RightPar }
  | "{" { LeftCurly }
  | "}" { RightCurly }
  | "[" { LeftSquare }
  | "]" { RightSquare }
  | "+" { Plus }
  | "-" { Minus }
  | "*" { Times }
  | "/" { Divide }
  | digits+ as n { Int (int_of_string n) }
  | alpha (alpha | digits)* as i { Id i }
  | "\"" (str_char* as str) "\"" { Str str }
