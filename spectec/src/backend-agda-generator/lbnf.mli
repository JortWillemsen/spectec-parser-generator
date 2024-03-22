
type identifier = string
type comment    = string

(* Type synonyms *)
type label    = identifier 
type category = identifier

(* Definition of grammar rule *)
type def =
  | Def of label * category * list_item * comment
(* 
and list_def =
  | DefEps                    (*  ε                    *)
  | DefCons of def * list_def (*  <Item> <ListItem>  *)
   
*)


(* Item specifying th grammar rule's (non)terminals *)
type item =
  | Terminal    of string        (*  <String> *)
  | NonTerminal of category      (*  <Cat> *)
and list_item =
  | Eps                          (*  ε                    *)
  | ItemCons of item * list_item (*  <Item> <ListItem>  *)


type specification = def list




(*
OLD AST

type minimum_size =
  | MinimumSizeEps 
  | Size of nonempty (* todo nonempty *)

type rhs = 
  | RHS of list_item

type list_rhs =
  | ListRHS of rhs 
  | ListRHSCons of rhs list_rhsb

type list_string = 
  | ListStringString of string 
  | ListStringCons of string * list_string


type label = 
  | LabelId of identifier 
  | WildCardLabel 
  | SquareBracketsLabel
  | ParensCons
  | ParensConsList

type cat =
  | CatGroup of cat     (*  <Cat> *)
  | CatId of identifier (*  <Identifier> *)


type item =
  | Item of string  (*  <String> *)
  | CatItem of cat  (*  <Cat> *)

type list_item =
  | ListItemEps                  (*  ε                    *)
  | ItemCons of item * list_item (*  <Item> , <ListItem>  *)

type list_cat =
  | Cat of cat                (*  <Cat>               *)
  | CatCons of cat * list_cat (*  <Cat> , <ListCat>   *)

type def =
  | Entrypoints     of list_cat

  | Expr            of label * cat * list_item 
  | InternalExpr    of label * cat * list_item 

  | Separator       of minimum_size * cat * string 
  | Terminator      of minimum_size * cat * string 
  | Coercions       of identifier * int 
  | Rules           of identifier * list_rhs
  | Comment         of string 
  | Comment2        of string * string
  | Token           of identifier * reg 
  | PositionedToken of identifier * reg 
  | Layout          of list_string 
  | LayoutStop      of list_string
  | LayoutTopLevel  of list_string

type list_def = 
  | ListDefEps                (*  ε                 *)
  | Def     of def            (*  <Def>             *)
  | DefCons of def * list_def (*  <Def> ; <ListDef> *)
  | Cons    of list_def       (*  ; <ListDef>       *)

type specification = list_def
*)