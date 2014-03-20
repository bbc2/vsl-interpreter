type value =
  | Int of int
  | IntArray of int array

let get_int value =
  match value with
  | Int i -> i
  | _ -> failwith "Wrong type, expected Int _"

let get_intarray value =
  match value with
  | IntArray a -> a
  | _ -> failwith "Wrong type, expected IntArray _"
