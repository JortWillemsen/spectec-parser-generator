module Translate = struct
  open Util.Source
  open Il

(* 

 let rec process_def env (d : Ast.def) =
  match d.it with
  | TypD (i,prms,insts) ->    (* syntax type (family) *)
  


  
  | DecD (i, tin, typ, clauses) -> 
    let productions = map process_clause clauses in
      let commnt = toString (i, tin, typ ....) in 
      (* productions to list of defs? *)
        Def (i, i, productions, commnt)
  | _ -> raise Failure (* Should be some ignore *)

  let rec process_clause env (d : Ast.clause) =
    | DefD (bindList, argList, exp, premise_list)
   
*)

(*   
  and script env sc =
    List.fold_left
      (fun (defs, env) d ->
        let defs', env' = def env d in
        (defs @ defs', env'))
      ([], env) sc    *)
end


let script sc =
  let sc', _env = Translate.script Translate.initial_env sc in
  sc'
