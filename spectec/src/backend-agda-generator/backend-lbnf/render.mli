open El.Ast


(* Environment *)
(* 
type env

val env : Config.t -> El.Ast.script -> env
val env_with_config : env -> Config.t -> env 
val config : env -> Config.t 

val with_syntax_decoration : bool -> env -> env
val with_rule_decoration : bool -> env -> env  *)


(* Generators *)

(* val render_atom   : atom -> string
val render_typ    : typ -> string
val render_exp    : exp -> string
val render_arg    : arg -> string
val render_def    : def -> string
val render_defs   : def list -> string *)
val render_script : script -> string
