module Translate = struct
  open Util.Source
  open Il

  (* type env = {
    records_with_comp : Agda.id list;
    variants : (string * Ast.typcase list) list;
    relations : (string * (Ast.typ * Ast.rule list)) list;
  } *)

  (* let initial_env = { records_with_comp = []; variants = []; relations = [] } *)

  (* .... *)



  (* 
  and script env sc =
    List.fold_left
      (fun (defs, env) d ->
        let defs', env' = def env d in
        (defs @ defs', env'))
      ([], env) sc   
  *)
end


let script sc =
  let sc', _env = Translate.script Translate.initial_env sc in
  sc'
