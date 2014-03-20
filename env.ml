module SMap = Map.Make(String)

let empty = SMap.empty::[]

let push env = SMap.empty::env

let pop env = match env with
  | [] -> failwith "Trying to pop an empty env"
  | _::tl -> tl

let add ref value env = match env with
  | [] -> failwith "Trying to bind on an empty env"
  | cur::tl -> (SMap.add ref value cur)::tl

let bind assoc env = match env with
  | [] -> failwith "Trying to bind on an empty env"
  | cur::tl ->
      let rec bind_rec assoc acc = match assoc with
      | [] -> acc
      | (ref, value)::tl -> bind_rec tl (SMap.add ref value acc)
      in
      (bind_rec assoc cur)::tl

let rec find ref env = match env with
  | [] -> failwith (Printf.sprintf "Unbound variable %s" ref)
  | cur::tl -> try SMap.find ref cur
               with Not_found -> find ref tl

