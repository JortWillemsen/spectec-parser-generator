(* 
Temp AST   
*)


(* 
type keywords =
  | Char         
  (* | Coercions   *)
  (* | Comment *)
  | Digit
  (* | Entrypoints   *)
  (* | Eps *)
  (* | Internal *)
  (* | Layout        *)
  | Letter     
  | Lower
  | Upper
  | Nonempty
  (* | Position *)
  (* | Rules *)
  (* | Separator     *)
  (* | Stop *)
  (* | Terminator   *)
  (* | Token       *)
  (* | Toplevel *)   
*)

(* type symbols =
 | SemiColon    (*  ;    *)
 | Dot          (*  .    *)
 | Ass          (*  ::=  *)
 | SquareOpen   (*  [    *)
 | SquareClose  (*  ]    *)
 | WildCard     (*  _    *)
 | ParensOpen   (*  (    *)
 | ParensClose  (*  )    *)
 | SemiColon    (*  :    *)
 | Comma        (*  ,    *)
 | Pipe         (*  |    *)
 | Hyphen       (*  -    *)
 | Mult         (*  *    *)
 | Plus         (*  +    *)
 | QuestionMark (*  ?    *)
 | BracketOpen  (*  {    *)
 | BracketClose  }    *)

type reg3 = 
  | Many of reg3                (*  *  *)
  | OneMany of reg3             (*  +  *)
  | OptionalOFLAZY? of reg3            (*  +  *)
  | Eps                         (*  ε  *)
  | CharThing of char                (* <char>  - any non metacharacter | '\' metacharacter *)
    (*
  | Letter char    (* letter  *)
  | Upper    (* upper  *)
  | Lower    (* lower  *)
  | Char    (* char  *)   
  *)
  | StringClass/StringList of string (*  [ <String> ]  *)
  | StringOtherGourp? of string    (* { <String> }  *)
  | Digit int    (* digit  *)
  | Parens of reg3    (* ( <Reg> )  *)  


  (* 
  | Many of reg3                (*  *  *)
  | OneMany of reg3             (*  +  *)
  | OptionalOFLAZY? of reg3            (*  +  *)
  | Eps                         (*  ε  *)
  | CharThing of char                (* <char>  - any non metacharacter | '\' metacharacter *)
  | StringClass/StringList of (string list) (*  [ <String> ]  *)
  |     (* { <String> }  *)
  | Digit int    (* digit  *)
  | Letter char    (* letter  *)
  | Upper    (* upper  *)
  | Lower    (* lower  *)
  | Char    (* char  *)
  | Parens of reg3    (* ( <Reg> )  *)     
*)


type identifier = string

type reg2 =
  | Reg2 of reg2 * reg3
  | Reg2Reg3 of reg3

type reg1 =
  | Reg1Hyphened of reg1 * reg2 
  | Reg1Reg2 of reg2

type reg = 
  | Reg of reg * reg1 
  | RegReg1 of reg1

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
  | Entrypoints of list_cat
  | Expr of label * cat * list_item 
  | InternalExpr of label * cat * list_item 
  | Separator of minimum_size * cat * string 
  | Terminator of minimum_size * cat * string 
  | Coercions of identifier * int 
  | Rules of identifier * list_rhs
  | Comment of string 
  | Comment2 of string * string
  | Token of identifier * reg 
  | PositionedToken of identifier * reg 
  | Layout of list_string 
  | LayoutStop of list_string
  | LayoutTopLevel of list_string

type list_def = 
  | ListDefEps                (*  ε                 *)
  | Def     of def            (*  <Def>             *)
  | DefCons of def * list_def (*  <Def> ; <ListDef> *)
  | Cons    of list_def       (*  ; <ListDef>       *)

type specification = list_def