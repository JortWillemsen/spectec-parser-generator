open import Data.Bool using (Bool; true; false)
open import Data.Fin using (fromℕ<)
open import Data.Product using (_×_) renaming (_,_ to  ⟨_,_⟩)
open import Data.List using (List; map; _∷_; []; length; _++_; lookup; _[_]∷=_)
open import Data.List.Relation.Unary.All using (All)
open import Data.List.Relation.Binary.Pointwise using (Pointwise)
open import Data.Maybe using (Maybe; just; nothing; _<∣>_) renaming (map to maybeMap)
open import Data.String using (String)
open import Data.Nat using (ℕ; zero; suc; _+_; _*_; _^_; _≤_; _<_; _≥_; _>_)
open import Data.Unit using (⊤; tt)
open import Relation.Binary.PropositionalEquality using (_≡_; _≢_)


ty-n : Set
ty-n  = ℕ

ty-name : Set
ty-name  = String

ty-byte : Set
ty-byte  = ℕ

ty-u32 : Set
ty-u32  = ℕ

ty-idx : Set
ty-idx  = ℕ

ty-funcidx : Set
ty-funcidx  = ty-idx

ty-globalidx : Set
ty-globalidx  = ty-idx

ty-labelidx : Set
ty-labelidx  = ty-idx

ty-localidx : Set
ty-localidx  = ty-idx

data ty-numtype : Set where
  I32 :
    ----------
    ty-numtype

data ty-valtype : Set
data ty-valtype where
  I32 : ty-valtype
  BOT : ty-valtype

$valtype-numtype : ty-numtype → ty-valtype
$valtype-numtype I32 = I32

data ty-in : Set
data ty-in where
  I32 :
    -----
    ty-in

ty-resulttype : Set
ty-resulttype  = List ty-valtype

ty-globaltype : Set
ty-globaltype  = ((Maybe (⊤)) × ty-valtype)

ty-functype : Set
ty-functype  = (ty-resulttype × ty-resulttype)

data ty-sx : Set
data ty-sx where
  U :
    -----
    ty-sx
  S :
    -----
    ty-sx

data ty-unop-IXX : Set
data ty-unop-IXX where
  CLZ :
    -----------
    ty-unop-IXX
  CTZ :
    -----------
    ty-unop-IXX
  POPCNT :
    -----------
    ty-unop-IXX

data ty-binop-IXX : Set
data ty-binop-IXX where
  ADD :
    ------------
    ty-binop-IXX
  SUB :
    ------------
    ty-binop-IXX
  MUL :
    ------------
    ty-binop-IXX
  DIV :
    ty-sx ->
    ------------
    ty-binop-IXX
  REM :
    ty-sx ->
    ------------
    ty-binop-IXX
  AND :
    ------------
    ty-binop-IXX
  OR :
    ------------
    ty-binop-IXX
  XOR :
    ------------
    ty-binop-IXX
  SHL :
    ------------
    ty-binop-IXX
  SHR :
    ty-sx ->
    ------------
    ty-binop-IXX
  ROTL :
    ------------
    ty-binop-IXX
  ROTR :
    ------------
    ty-binop-IXX

data ty-testop-IXX : Set
data ty-testop-IXX where
  EQZ :
    -------------
    ty-testop-IXX

data ty-relop-IXX : Set
data ty-relop-IXX where
  EQ :
    ------------
    ty-relop-IXX
  NE :
    ------------
    ty-relop-IXX
  LT :
    ty-sx ->
    ------------
    ty-relop-IXX
  GT :
    ty-sx ->
    ------------
    ty-relop-IXX
  LE :
    ty-sx ->
    ------------
    ty-relop-IXX
  GE :
    ty-sx ->
    ------------
    ty-relop-IXX

data ty-unop-numtype : Set
data ty-unop-numtype where
  -I :
    ty-unop-IXX ->
    ---------------
    ty-unop-numtype

data ty-binop-numtype : Set
data ty-binop-numtype where
  -I :
    ty-binop-IXX ->
    ----------------
    ty-binop-numtype

data ty-testop-numtype : Set
data ty-testop-numtype where
  -I :
    ty-testop-IXX ->
    -----------------
    ty-testop-numtype

data ty-relop-numtype : Set
data ty-relop-numtype where
  -I :
    ty-relop-IXX ->
    ----------------
    ty-relop-numtype

ty-c-numtype : Set
ty-c-numtype  = ℕ

ty-blocktype : Set
ty-blocktype  = ty-functype

data ty-instr : Set
data ty-instr where
  UNREACHABLE :
    --------
    ty-instr
  NOP :
    --------
    ty-instr
  DROP :
    --------
    ty-instr
  SELECT :
    Maybe ty-valtype ->
    ----------------
    ty-instr
  BLOCK :
    ty-blocktype ->
    List ty-instr ->
    -------------
    ty-instr
  LOOP :
    ty-blocktype ->
    List ty-instr ->
    -------------
    ty-instr
  IF :
    ty-blocktype ->
    List ty-instr ->
    List ty-instr ->
    -------------
    ty-instr
  BR :
    ty-labelidx ->
    -----------
    ty-instr
  BR-IF :
    ty-labelidx ->
    -----------
    ty-instr
  CALL :
    ty-funcidx ->
    ----------
    ty-instr
  RETURN :
    --------
    ty-instr
  CONST :
    ty-numtype ->
    ty-c-numtype ->
    ------------
    ty-instr
  UNOP :
    ty-numtype ->
    ty-unop-numtype ->
    ---------------
    ty-instr
  BINOP :
    ty-numtype ->
    ty-binop-numtype ->
    ----------------
    ty-instr
  TESTOP :
    ty-numtype ->
    ty-testop-numtype ->
    -----------------
    ty-instr
  RELOP :
    ty-numtype ->
    ty-relop-numtype ->
    ----------------
    ty-instr
  LOCAL-GET :
    ty-localidx ->
    -----------
    ty-instr
  LOCAL-SET :
    ty-localidx ->
    -----------
    ty-instr
  LOCAL-TEE :
    ty-localidx ->
    -----------
    ty-instr
  GLOBAL-GET :
    ty-globalidx ->
    ------------
    ty-instr
  GLOBAL-SET :
    ty-globalidx ->
    ------------
    ty-instr

ty-expr : Set
ty-expr  = List ty-instr

ty-func : Set
ty-func  = ((ty-functype × (List ty-valtype)) × ty-expr)

ty-global : Set
ty-global  = (ty-globaltype × ty-expr)

ty-start : Set
ty-start  = ty-funcidx

ty-module : Set
ty-module  = (((List ty-func) × (List ty-global)) × (List ty-start))

$Ki : (⊤) → ℕ
$Ki _ = 1024

$min : ((ℕ × ℕ)) → ℕ
$min ⟨ 0 , j ⟩ = 0
$min ⟨ i , 0 ⟩ = 0
$min ⟨ suc i , suc j ⟩ = $min ⟨ i , j ⟩

$size : ty-valtype → (Maybe ℕ)
$size I32 = just 32
$size x = nothing

$test-sub-ATOM-22 : ty-n → ℕ
$test-sub-ATOM-22 n-3-ATOM-y = 0

$curried- : ((ty-n × ty-n)) → ℕ
$curried- ⟨ n-1 , n-2 ⟩ = n-1 + n-2

data ty-testfuse : Set
data ty-testfuse where
  AB- :
    ℕ ->
    ℕ ->
    ℕ ->
    -----------
    ty-testfuse
  CD :
    ℕ ->
    ℕ ->
    ℕ ->
    -----------
    ty-testfuse
  EF :
    ℕ ->
    ℕ ->
    ℕ ->
    -----------
    ty-testfuse
  GH :
    ℕ ->
    ℕ ->
    ℕ ->
    -----------
    ty-testfuse
  IJ :
    ℕ ->
    ℕ ->
    ℕ ->
    -----------
    ty-testfuse
  KL :
    ℕ ->
    ℕ ->
    ℕ ->
    -----------
    ty-testfuse
  MN :
    ℕ ->
    ℕ ->
    ℕ ->
    -----------
    ty-testfuse
  OP :
    ℕ ->
    ℕ ->
    ℕ ->
    -----------
    ty-testfuse
  QR :
    ℕ ->
    ℕ ->
    ℕ ->
    -----------
    ty-testfuse

record ty-context : Set
record ty-context where
  field
    FUNC : List ty-functype
    GLOBAL : List ty-globaltype
    LOCAL : List ty-valtype
    LABEL : List ty-resulttype
    RETURNS : Maybe ty-resulttype

_++ty-context_ : ty-context → (ty-context → ty-context)
_++ty-context_ x1 x2 = record { FUNC = (ty-context.FUNC x1) ++ (ty-context.FUNC x2) ; GLOBAL = (ty-context.GLOBAL x1) ++ (ty-context.GLOBAL x2) ; LOCAL = (ty-context.LOCAL x1) ++ (ty-context.LOCAL x2) ; LABEL = (ty-context.LABEL x1) ++ (ty-context.LABEL x2) ; RETURNS = (ty-context.RETURNS x1) <∣> (ty-context.RETURNS x2) }

data ty-Functype-ok : ty-functype → Set
data ty-Functype-ok where
  - :
    (ft : ty-functype) ->
    -----------------
    ty-Functype-ok ft

data ty-Globaltype-ok : ty-globaltype → Set
data ty-Globaltype-ok where
  - :
    (gt : ty-globaltype) ->
    -------------------
    ty-Globaltype-ok gt

data ty-Blocktype-ok : (((ty-context × ty-blocktype) × ty-functype)) → Set
data ty-Blocktype-ok where
  - :
    (C : ty-context) (ft : ty-functype) ->
    ty-Functype-ok ft ->
    -----------------------------------
    ty-Blocktype-ok ⟨ ⟨ C , ft ⟩ , ft ⟩

data ty-Instr-ok : (((ty-context × ty-instr) × ty-functype)) → Set
data ty-InstrSeq-ok : (((ty-context × (List ty-instr)) × ty-functype)) → Set
data ty-Instr-ok where
  unreachable :
    (C : ty-context) (t-1 : List ty-valtype) (t-2 : List ty-valtype) ->
    ---------------------------------------------------
    ty-Instr-ok ⟨ ⟨ C , UNREACHABLE ⟩ , ⟨ t-1 , t-2 ⟩ ⟩
  nop :
    (C : ty-context) ->
    -----------------------------------------
    ty-Instr-ok ⟨ ⟨ C , NOP ⟩ , ⟨ [] , [] ⟩ ⟩
  drop :
    (C : ty-context) (t : ty-valtype) ->
    ----------------------------------------------
    ty-Instr-ok ⟨ ⟨ C , DROP ⟩ , ⟨ t ∷ [] , [] ⟩ ⟩
  select-expl :
    (C : ty-context) (t : ty-valtype) ->
    ---------------------------------------------------------------------------
    ty-Instr-ok ⟨ ⟨ C , SELECT (just t) ⟩ , ⟨ t ∷ (t ∷ (I32 ∷ [])) , t ∷ [] ⟩ ⟩
  select-impl :
    (C : ty-context) (numtype : ty-numtype) (t : ty-valtype) ->
    t ≡ ($valtype-numtype numtype) ->
    --------------------------------------------------------------------------
    ty-Instr-ok ⟨ ⟨ C , SELECT nothing ⟩ , ⟨ t ∷ (t ∷ (I32 ∷ [])) , t ∷ [] ⟩ ⟩
  block :
    (C : ty-context) (bt : ty-blocktype) (instr : List ty-instr) (t-1 : List ty-valtype) (t-2 : List ty-valtype) ->
    ty-Blocktype-ok ⟨ ⟨ C , bt ⟩ , ⟨ t-1 , t-2 ⟩ ⟩ ->
    ty-InstrSeq-ok ⟨ ⟨ C ++ty-context (record { FUNC = [] ; GLOBAL = [] ; LOCAL = [] ; LABEL = (map (λ t-2 -> (t-2 ∷ []))) t-2 ; RETURNS = nothing }) , instr ⟩ , ⟨ t-1 , t-2 ⟩ ⟩ ->
    -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    ty-Instr-ok ⟨ ⟨ C , BLOCK bt instr ⟩ , ⟨ t-1 , t-2 ⟩ ⟩
  loop :
    (C : ty-context) (bt : ty-blocktype) (instr : List ty-instr) (t-1 : List ty-valtype) (t-2 : List ty-valtype) ->
    ty-Blocktype-ok ⟨ ⟨ C , bt ⟩ , ⟨ t-1 , t-2 ⟩ ⟩ ->
    ty-InstrSeq-ok ⟨ ⟨ C ++ty-context (record { FUNC = [] ; GLOBAL = [] ; LOCAL = [] ; LABEL = (map (λ t-1 -> (t-1 ∷ []))) t-1 ; RETURNS = nothing }) , instr ⟩ , ⟨ t-1 , t-2 ⟩ ⟩ ->
    -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    ty-Instr-ok ⟨ ⟨ C , LOOP bt instr ⟩ , ⟨ t-1 , t-2 ⟩ ⟩
  if :
    (C : ty-context) (bt : ty-blocktype) (instr-1 : List ty-instr) (instr-2 : List ty-instr) (t-1 : List ty-valtype) (t-2 : List ty-valtype) ->
    ty-Blocktype-ok ⟨ ⟨ C , bt ⟩ , ⟨ t-1 , t-2 ⟩ ⟩ ->
    ty-InstrSeq-ok ⟨ ⟨ C ++ty-context (record { FUNC = [] ; GLOBAL = [] ; LOCAL = [] ; LABEL = (map (λ t-2 -> (t-2 ∷ []))) t-2 ; RETURNS = nothing }) , instr-1 ⟩ , ⟨ t-1 , t-2 ⟩ ⟩ ->
    ty-InstrSeq-ok ⟨ ⟨ C ++ty-context (record { FUNC = [] ; GLOBAL = [] ; LOCAL = [] ; LABEL = (map (λ t-2 -> (t-2 ∷ []))) t-2 ; RETURNS = nothing }) , instr-2 ⟩ , ⟨ t-1 , t-2 ⟩ ⟩ ->
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    ty-Instr-ok ⟨ ⟨ C , IF bt instr-1 instr-2 ⟩ , ⟨ t-1 , t-2 ⟩ ⟩
  br :
    (C : ty-context) (l : ty-labelidx) (t : List ty-valtype) (t-1 : List ty-valtype) (t-2 : List ty-valtype) ->
    l < (length (ty-context.LABEL C)) ->
    ((lookup (ty-context.LABEL C)) {!   !} {- idx -}) ≡ t ->
    -----------------------------------------------------
    ty-Instr-ok ⟨ ⟨ C , BR l ⟩ , ⟨ t-1 ++ t , t-2 ⟩ ⟩
  br-if :
    (C : ty-context) (l : ty-labelidx) (t : List ty-valtype) ->
    l < (length (ty-context.LABEL C)) ->
    ((lookup (ty-context.LABEL C)) {!   !} {- idx -}) ≡ t ->
    ---------------------------------------------------------
    ty-Instr-ok ⟨ ⟨ C , BR-IF l ⟩ , ⟨ t ++ (I32 ∷ []) , t ⟩ ⟩
  return :
    (C : ty-context) (t : List ty-valtype) (t-1 : List ty-valtype) (t-2 : List ty-valtype) ->
    (ty-context.RETURNS C) ≡ (just t) ->
    ---------------------------------------------------
    ty-Instr-ok ⟨ ⟨ C , RETURN ⟩ , ⟨ t-1 ++ t , t-2 ⟩ ⟩
  call :
    (C : ty-context) (t-1 : List ty-valtype) (t-2 : List ty-valtype) (x : ty-idx) ->
    x < (length (ty-context.FUNC C)) ->
    ((lookup (ty-context.FUNC C)) {!   !} {- idx -}) ≡ ⟨ t-1 , t-2 ⟩ ->
    ----------------------------------------------------------------
    ty-Instr-ok ⟨ ⟨ C , CALL x ⟩ , ⟨ t-1 , t-2 ⟩ ⟩
  const :
    (C : ty-context) (c-nt : ty-c-numtype) (nt : ty-numtype) ->
    ---------------------------------------------------------------------------
    ty-Instr-ok ⟨ ⟨ C , CONST nt c-nt ⟩ , ⟨ [] , ($valtype-numtype nt) ∷ [] ⟩ ⟩
  unop :
    (C : ty-context) (nt : ty-numtype) (unop : ty-unop-numtype) ->
    --------------------------------------------------------------------------------------------------
    ty-Instr-ok ⟨ ⟨ C , UNOP nt unop ⟩ , ⟨ ($valtype-numtype nt) ∷ [] , ($valtype-numtype nt) ∷ [] ⟩ ⟩
  binop :
    (C : ty-context) (binop : ty-binop-numtype) (nt : ty-numtype) ->
    ------------------------------------------------------------------------------------------------------------------------------
    ty-Instr-ok ⟨ ⟨ C , BINOP nt binop ⟩ , ⟨ ($valtype-numtype nt) ∷ (($valtype-numtype nt) ∷ []) , ($valtype-numtype nt) ∷ [] ⟩ ⟩
  testop :
    (C : ty-context) (nt : ty-numtype) (testop : ty-testop-numtype) ->
    ------------------------------------------------------------------------------------
    ty-Instr-ok ⟨ ⟨ C , TESTOP nt testop ⟩ , ⟨ ($valtype-numtype nt) ∷ [] , I32 ∷ [] ⟩ ⟩
  relop :
    (C : ty-context) (nt : ty-numtype) (relop : ty-relop-numtype) ->
    ------------------------------------------------------------------------------------------------------------
    ty-Instr-ok ⟨ ⟨ C , RELOP nt relop ⟩ , ⟨ ($valtype-numtype nt) ∷ (($valtype-numtype nt) ∷ []) , I32 ∷ [] ⟩ ⟩
  local-get :
    (C : ty-context) (t : ty-valtype) (x : ty-idx) ->
    x < (length (ty-context.LOCAL C)) ->
    ((lookup (ty-context.LOCAL C)) {!   !} {- idx -}) ≡ t ->
    -----------------------------------------------------
    ty-Instr-ok ⟨ ⟨ C , LOCAL-GET x ⟩ , ⟨ [] , t ∷ [] ⟩ ⟩
  local-set :
    (C : ty-context) (t : ty-valtype) (x : ty-idx) ->
    x < (length (ty-context.LOCAL C)) ->
    ((lookup (ty-context.LOCAL C)) {!   !} {- idx -}) ≡ t ->
    -----------------------------------------------------
    ty-Instr-ok ⟨ ⟨ C , LOCAL-SET x ⟩ , ⟨ t ∷ [] , [] ⟩ ⟩
  local-tee :
    (C : ty-context) (t : ty-valtype) (x : ty-idx) ->
    x < (length (ty-context.LOCAL C)) ->
    ((lookup (ty-context.LOCAL C)) {!   !} {- idx -}) ≡ t ->
    ---------------------------------------------------------
    ty-Instr-ok ⟨ ⟨ C , LOCAL-TEE x ⟩ , ⟨ t ∷ [] , t ∷ [] ⟩ ⟩
  global-get :
    (C : ty-context) (t : ty-valtype) (x : ty-idx) ->
    x < (length (ty-context.GLOBAL C)) ->
    ((lookup (ty-context.GLOBAL C)) {!   !} {- idx -}) ≡ ⟨ just (record { }) , t ⟩ ->
    ------------------------------------------------------------------------------
    ty-Instr-ok ⟨ ⟨ C , GLOBAL-GET x ⟩ , ⟨ [] , t ∷ [] ⟩ ⟩
  global-set :
    (C : ty-context) (t : ty-valtype) (x : ty-idx) ->
    x < (length (ty-context.GLOBAL C)) ->
    ((lookup (ty-context.GLOBAL C)) {!   !} {- idx -}) ≡ ⟨ just (record { }) , t ⟩ ->
    ------------------------------------------------------------------------------
    ty-Instr-ok ⟨ ⟨ C , GLOBAL-SET x ⟩ , ⟨ t ∷ [] , [] ⟩ ⟩
data ty-InstrSeq-ok where
  empty :
    (C : ty-context) ->
    -------------------------------------------
    ty-InstrSeq-ok ⟨ ⟨ C , [] ⟩ , ⟨ [] , [] ⟩ ⟩
  seq :
    (C : ty-context) (instr-1 : ty-instr) (instr-2 : ty-instr) (t-1 : List ty-valtype) (t-2 : List ty-valtype) (t-3 : List ty-valtype) ->
    ty-Instr-ok ⟨ ⟨ C , instr-1 ⟩ , ⟨ t-1 , t-2 ⟩ ⟩ ->
    ty-InstrSeq-ok ⟨ ⟨ C , instr-2 ∷ [] ⟩ , ⟨ t-2 , t-3 ⟩ ⟩ ->
    ---------------------------------------------------------------------------
    ty-InstrSeq-ok ⟨ ⟨ C , (instr-1 ∷ []) ++ (instr-2 ∷ []) ⟩ , ⟨ t-1 , t-3 ⟩ ⟩
  weak :
    (C : ty-context) (instr : List ty-instr) (t-1 : List ty-valtype) (t-2 : List ty-valtype) ->
    ty-InstrSeq-ok ⟨ ⟨ C , instr ⟩ , ⟨ t-1 , t-2 ⟩ ⟩ ->
    ------------------------------------------------
    ty-InstrSeq-ok ⟨ ⟨ C , instr ⟩ , ⟨ t-1 , t-2 ⟩ ⟩
  frame :
    (C : ty-context) (instr : List ty-instr) (t : List ty-valtype) (t-1 : List ty-valtype) (t-2 : List ty-valtype) ->
    ty-InstrSeq-ok ⟨ ⟨ C , instr ⟩ , ⟨ t-1 , t-2 ⟩ ⟩ ->
    ----------------------------------------------------------
    ty-InstrSeq-ok ⟨ ⟨ C , instr ⟩ , ⟨ t ++ t-1 , t ++ t-2 ⟩ ⟩

data ty-Expr-ok : (((ty-context × ty-expr) × ty-resulttype)) → Set
data ty-Expr-ok where
  - :
    (C : ty-context) (instr : List ty-instr) (t : List ty-valtype) ->
    ty-InstrSeq-ok ⟨ ⟨ C , instr ⟩ , ⟨ [] , t ⟩ ⟩ ->
    ---------------------------------------------
    ty-Expr-ok ⟨ ⟨ C , instr ⟩ , t ⟩

data ty-Instr-const : ((ty-context × ty-instr)) → Set
data ty-Instr-const where
  const :
    (C : ty-context) (c : ty-c-numtype) (nt : ty-numtype) ->
    ---------------------------------
    ty-Instr-const ⟨ C , CONST nt c ⟩
  global-get :
    (C : ty-context) (t : ty-valtype) (x : ty-idx) ->
    x < (length (ty-context.GLOBAL C)) ->
    ((lookup (ty-context.GLOBAL C)) {!   !} {- idx -}) ≡ ⟨ nothing , t ⟩ ->
    --------------------------------------------------------------------
    ty-Instr-const ⟨ C , GLOBAL-GET x ⟩

data ty-Expr-const : ((ty-context × ty-expr)) → Set
data ty-Expr-const where
  - :
    (C : ty-context) (instr : List ty-instr) ->
    (All (λ instr -> (ty-Instr-const ⟨ C , instr ⟩))) instr ->
    -------------------------------------------------------
    ty-Expr-const ⟨ C , instr ⟩

data ty-Expr-ok-const : (((ty-context × ty-expr) × ty-valtype)) → Set
data ty-Expr-ok-const where
  - :
    (C : ty-context) (expr : ty-expr) (t : ty-valtype) ->
    ty-Expr-ok ⟨ ⟨ C , expr ⟩ , t ∷ [] ⟩ ->
    ty-Expr-const ⟨ C , expr ⟩ ->
    -------------------------------------
    ty-Expr-ok-const ⟨ ⟨ C , expr ⟩ , t ⟩

data ty-Func-ok : (((ty-context × ty-func) × ty-functype)) → Set
data ty-Func-ok where
  - :
    (C : ty-context) (expr : ty-expr) (ft : ty-functype) (t : List ty-valtype) (t-1 : List ty-valtype) (t-2 : List ty-valtype) ->
    ft ≡ ⟨ t-1 , t-2 ⟩ ->
    ty-Functype-ok ft ->
    ty-Expr-ok ⟨ ⟨ ((C ++ty-context (record { FUNC = [] ; GLOBAL = [] ; LOCAL = t-1 ++ t ; LABEL = [] ; RETURNS = nothing })) ++ty-context (record { FUNC = [] ; GLOBAL = [] ; LOCAL = [] ; LABEL = t-2 ∷ [] ; RETURNS = nothing })) ++ty-context (record { FUNC = [] ; GLOBAL = [] ; LOCAL = [] ; LABEL = [] ; RETURNS = just t-2 }) , expr ⟩ , t-2 ⟩ ->
    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    ty-Func-ok ⟨ ⟨ C , ⟨ ⟨ ft , t ⟩ , expr ⟩ ⟩ , ft ⟩

data ty-Global-ok : (((ty-context × ty-global) × ty-globaltype)) → Set
data ty-Global-ok where
  - :
    (C : ty-context) (expr : ty-expr) (gt : ty-globaltype) (t : ty-valtype) ->
    ty-Globaltype-ok gt ->
    gt ≡ ⟨ just (record { }) , t ⟩ ->
    ty-Expr-ok-const ⟨ ⟨ C , expr ⟩ , t ⟩ ->
    -------------------------------------------
    ty-Global-ok ⟨ ⟨ C , ⟨ gt , expr ⟩ ⟩ , gt ⟩

data ty-Start-ok : ((ty-context × ty-start)) → Set
data ty-Start-ok where
  - :
    (C : ty-context) (x : ty-idx) ->
    x < (length (ty-context.FUNC C)) ->
    ((lookup (ty-context.FUNC C)) {!   !} {- idx -}) ≡ ⟨ [] , [] ⟩ ->
    --------------------------------------------------------------
    ty-Start-ok ⟨ C , x ⟩

data ty-Module-ok : ty-module → Set
data ty-Module-ok where
  - :
    (C : ty-context) (ft : List ty-functype) (func : List ty-func) (global : List ty-global) (gt : List ty-globaltype) (start : List ty-start) ->
    (length ft) ≡ (length func) ->
    (length global) ≡ (length gt) ->
    C ≡ (record { FUNC = ft ; GLOBAL = gt ; LOCAL = [] ; LABEL = [] ; RETURNS = nothing }) ->
    ((Pointwise (λ ft -> (λ func -> (ty-Func-ok ⟨ ⟨ C , func ⟩ , ft ⟩)))) ft) func ->
    ((Pointwise (λ global -> (λ gt -> (ty-Global-ok ⟨ ⟨ C , global ⟩ , gt ⟩)))) global) gt ->
    (All (λ start -> (ty-Start-ok ⟨ C , start ⟩))) start ->
    (length start) ≤ 1 ->
    --------------------------------------------------------------------------------------
    ty-Module-ok ⟨ ⟨ func , global ⟩ , start ⟩

ty-addr : Set
ty-addr  = ℕ

ty-funcaddr : Set
ty-funcaddr  = ty-addr

ty-globaladdr : Set
ty-globaladdr  = ty-addr

ty-labeladdr : Set
ty-labeladdr  = ty-addr

ty-hostaddr : Set
ty-hostaddr  = ty-addr

data ty-num : Set
data ty-num where
  CONST :
    ty-numtype ->
    ty-c-numtype ->
    ------------
    ty-num

data ty-val : Set
data ty-val where
  CONST :
    ty-numtype ->
    ty-c-numtype ->
    ------------
    ty-val

data ty-result : Set
data ty-result where
  -VALS :
    List ty-val ->
    -----------
    ty-result
  TRAP :
    ---------
    ty-result

$default- : ty-valtype → (Maybe ty-val)
$default- I32 = just (CONST I32 0)
$default- x = nothing

record ty-moduleinst : Set
record ty-moduleinst where
  field
    FUNC : List ty-funcaddr
    GLOBAL : List ty-globaladdr

_++ty-moduleinst_ : ty-moduleinst → (ty-moduleinst → ty-moduleinst)
_++ty-moduleinst_ x1 x2 = record { FUNC = (ty-moduleinst.FUNC x1) ++ (ty-moduleinst.FUNC x2) ; GLOBAL = (ty-moduleinst.GLOBAL x1) ++ (ty-moduleinst.GLOBAL x2) }

ty-funcinst : Set
ty-funcinst  = (ty-moduleinst × ty-func)

ty-globalinst : Set
ty-globalinst  = ty-val

record ty-store : Set
record ty-store where
  field
    FUNC : List ty-funcinst
    GLOBAL : List ty-globalinst

_++ty-store_ : ty-store → (ty-store → ty-store)
_++ty-store_ x1 x2 = record { FUNC = (ty-store.FUNC x1) ++ (ty-store.FUNC x2) ; GLOBAL = (ty-store.GLOBAL x1) ++ (ty-store.GLOBAL x2) }

record ty-frame : Set
record ty-frame where
  field
    LOCAL : List ty-val
    MODULE : ty-moduleinst

_++ty-frame_ : ty-frame → (ty-frame → ty-frame)
_++ty-frame_ x1 x2 = record { LOCAL = (ty-frame.LOCAL x1) ++ (ty-frame.LOCAL x2) ; MODULE = (ty-frame.MODULE x1) ++ty-moduleinst (ty-frame.MODULE x2) }

ty-state : Set
ty-state  = (ty-store × ty-frame)

data ty-admininstr : Set
data ty-admininstr where
  UNREACHABLE :
    -------------
    ty-admininstr
  NOP :
    -------------
    ty-admininstr
  DROP :
    -------------
    ty-admininstr
  SELECT :
    Maybe ty-valtype ->
    ----------------
    ty-admininstr
  BLOCK :
    ty-blocktype ->
    List ty-instr ->
    -------------
    ty-admininstr
  LOOP :
    ty-blocktype ->
    List ty-instr ->
    -------------
    ty-admininstr
  IF :
    ty-blocktype ->
    List ty-instr ->
    List ty-instr ->
    -------------
    ty-admininstr
  BR :
    ty-labelidx ->
    -------------
    ty-admininstr
  BR-IF :
    ty-labelidx ->
    -------------
    ty-admininstr
  CALL :
    ty-funcidx ->
    -------------
    ty-admininstr
  RETURN :
    -------------
    ty-admininstr
  CONST :
    ty-numtype ->
    ty-c-numtype ->
    -------------
    ty-admininstr
  UNOP :
    ty-numtype ->
    ty-unop-numtype ->
    ---------------
    ty-admininstr
  BINOP :
    ty-numtype ->
    ty-binop-numtype ->
    ----------------
    ty-admininstr
  TESTOP :
    ty-numtype ->
    ty-testop-numtype ->
    -----------------
    ty-admininstr
  RELOP :
    ty-numtype ->
    ty-relop-numtype ->
    ----------------
    ty-admininstr
  LOCAL-GET :
    ty-localidx ->
    -------------
    ty-admininstr
  LOCAL-SET :
    ty-localidx ->
    -------------
    ty-admininstr
  LOCAL-TEE :
    ty-localidx ->
    -------------
    ty-admininstr
  GLOBAL-GET :
    ty-globalidx ->
    -------------
    ty-admininstr
  GLOBAL-SET :
    ty-globalidx ->
    -------------
    ty-admininstr
  CALL-ADDR :
    ty-funcaddr ->
    -------------
    ty-admininstr
  LABEL- :
    ty-n ->
    List ty-instr ->
    List ty-admininstr ->
    ------------------
    ty-admininstr
  FRAME- :
    ty-n ->
    ty-frame ->
    List ty-admininstr ->
    ------------------
    ty-admininstr
  TRAP :
    -------------
    ty-admininstr

$admininstr-globalinst : ty-globalinst → ty-admininstr
$admininstr-globalinst (CONST x0 x1) = CONST x0 x1

$admininstr-instr : ty-instr → ty-admininstr
$admininstr-instr UNREACHABLE = UNREACHABLE
$admininstr-instr NOP = NOP
$admininstr-instr DROP = DROP
$admininstr-instr (SELECT x) = SELECT x
$admininstr-instr (BLOCK x0 x1) = BLOCK x0 x1
$admininstr-instr (LOOP x0 x1) = LOOP x0 x1
$admininstr-instr (IF x0 x1 x2) = IF x0 x1 x2
$admininstr-instr (BR x) = BR x
$admininstr-instr (BR-IF x) = BR-IF x
$admininstr-instr (CALL x) = CALL x
$admininstr-instr RETURN = RETURN
$admininstr-instr (CONST x0 x1) = CONST x0 x1
$admininstr-instr (UNOP x0 x1) = UNOP x0 x1
$admininstr-instr (BINOP x0 x1) = BINOP x0 x1
$admininstr-instr (TESTOP x0 x1) = TESTOP x0 x1
$admininstr-instr (RELOP x0 x1) = RELOP x0 x1
$admininstr-instr (LOCAL-GET x) = LOCAL-GET x
$admininstr-instr (LOCAL-SET x) = LOCAL-SET x
$admininstr-instr (LOCAL-TEE x) = LOCAL-TEE x
$admininstr-instr (GLOBAL-GET x) = GLOBAL-GET x
$admininstr-instr (GLOBAL-SET x) = GLOBAL-SET x

$admininstr-val : ty-val → ty-admininstr
$admininstr-val (CONST x0 x1) = CONST x0 x1

ty-config : Set
ty-config  = (ty-state × (List ty-admininstr))

$funcaddr : ty-state → (List ty-funcaddr)
$funcaddr ⟨ s , f ⟩ = ty-moduleinst.FUNC (ty-frame.MODULE f)

$funcinst : ty-state → (List ty-funcinst)
$funcinst ⟨ s , f ⟩ = ty-store.FUNC s

$func : ((ty-state × ty-funcidx)) → ty-funcinst
$func ⟨ ⟨ s , f ⟩ , x ⟩ = (lookup (ty-store.FUNC s)) {!   !} {- idx -}

$global : ((ty-state × ty-globalidx)) → ty-globalinst
$global ⟨ ⟨ s , f ⟩ , x ⟩ = (lookup (ty-store.GLOBAL s)) {!   !} {- idx -}

$local : ((ty-state × ty-localidx)) → ty-val
$local ⟨ ⟨ s , f ⟩ , x ⟩ = (lookup (ty-frame.LOCAL f)) {!   !} {- idx -}

$with-local : (((ty-state × ty-localidx) × ty-val)) → ty-state
$with-local ⟨ ⟨ ⟨ s , f ⟩ , x ⟩ , v ⟩ = ⟨ s , record f { LOCAL = ((ty-frame.LOCAL f) [ {!   !} {- upd -} ]∷= v) } ⟩

$with-global : (((ty-state × ty-globalidx) × ty-val)) → ty-state
$with-global ⟨ ⟨ ⟨ s , f ⟩ , x ⟩ , v ⟩ = ⟨ record s { GLOBAL = ((ty-store.GLOBAL s) [ {!   !} {- upd -} ]∷= v) } , f ⟩

data ty-E : Set
data ty-E where
  -HOLE :
    ----
    ty-E
  -SEQ :
    List ty-val ->
    ty-E ->
    List ty-instr ->
    -------------
    ty-E
  LABEL- :
    ty-n ->
    List ty-instr ->
    ty-E ->
    -------------
    ty-E

$unop : (((ty-unop-numtype × ty-numtype) × ty-c-numtype)) → (List ty-c-numtype)


$binop : ((((ty-binop-numtype × ty-numtype) × ty-c-numtype) × ty-c-numtype)) → (List ty-c-numtype)


$testop : (((ty-testop-numtype × ty-numtype) × ty-c-numtype)) → ty-c-numtype


$relop : ((((ty-relop-numtype × ty-numtype) × ty-c-numtype) × ty-c-numtype)) → ty-c-numtype


data ty-Step-pure : (((List ty-admininstr) × (List ty-admininstr))) → Set
data ty-Step-pure where
  unreachable :
    ---------------------------------------------
    ty-Step-pure ⟨ UNREACHABLE ∷ [] , TRAP ∷ [] ⟩
  nop :
    ------------------------------
    ty-Step-pure ⟨ NOP ∷ [] , [] ⟩
  drop :
    (val : ty-val) ->
    ---------------------------------------------------------
    ty-Step-pure ⟨ ($admininstr-val val) ∷ (DROP ∷ []) , [] ⟩
  select-true :
    (c : ty-c-numtype) (t : Maybe ty-valtype) (val-1 : ty-val) (val-2 : ty-val) ->
    c ≢ 0 ->
    -----------------------------------------------------------------------------------------------------------------------------------------
    ty-Step-pure ⟨ ($admininstr-val val-1) ∷ (($admininstr-val val-2) ∷ ((CONST I32 c) ∷ ((SELECT t) ∷ []))) , ($admininstr-val val-1) ∷ [] ⟩
  select-false :
    (c : ty-c-numtype) (t : Maybe ty-valtype) (val-1 : ty-val) (val-2 : ty-val) ->
    c ≡ 0 ->
    -----------------------------------------------------------------------------------------------------------------------------------------
    ty-Step-pure ⟨ ($admininstr-val val-1) ∷ (($admininstr-val val-2) ∷ ((CONST I32 c) ∷ ((SELECT t) ∷ []))) , ($admininstr-val val-2) ∷ [] ⟩
  block :
    (bt : ty-blocktype) (instr : List ty-instr) (k : ℕ) (n : ty-n) (t-1 : List ty-valtype) (t-2 : List ty-valtype) (val : List ty-val) ->
    (length t-1) ≡ k ->
    (length t-2) ≡ n ->
    (length val) ≡ k ->
    bt ≡ ⟨ t-1 , t-2 ⟩ ->
    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    ty-Step-pure ⟨ ((map (λ val -> ($admininstr-val val))) val) ++ ((BLOCK bt instr) ∷ []) , (LABEL- n [] (((map (λ val -> ($admininstr-val val))) val) ++ ((map (λ instr -> ($admininstr-instr instr))) instr))) ∷ [] ⟩
  loop :
    (bt : ty-blocktype) (instr : List ty-instr) (k : ℕ) (n : ty-n) (t-1 : List ty-valtype) (t-2 : List ty-valtype) (val : List ty-val) ->
    (length t-1) ≡ k ->
    (length t-2) ≡ n ->
    (length val) ≡ k ->
    bt ≡ ⟨ t-1 , t-2 ⟩ ->
    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    ty-Step-pure ⟨ ((map (λ val -> ($admininstr-val val))) val) ++ ((LOOP bt instr) ∷ []) , (LABEL- n ((LOOP bt instr) ∷ []) (((map (λ val -> ($admininstr-val val))) val) ++ ((map (λ instr -> ($admininstr-instr instr))) instr))) ∷ [] ⟩
  if-true :
    (bt : ty-blocktype) (c : ty-c-numtype) (instr-1 : List ty-instr) (instr-2 : List ty-instr) ->
    c ≢ 0 ->
    -----------------------------------------------------------------------------------------
    ty-Step-pure ⟨ (CONST I32 c) ∷ ((IF bt instr-1 instr-2) ∷ []) , (BLOCK bt instr-1) ∷ [] ⟩
  if-false :
    (bt : ty-blocktype) (c : ty-c-numtype) (instr-1 : List ty-instr) (instr-2 : List ty-instr) ->
    c ≡ 0 ->
    -----------------------------------------------------------------------------------------
    ty-Step-pure ⟨ (CONST I32 c) ∷ ((IF bt instr-1 instr-2) ∷ []) , (BLOCK bt instr-2) ∷ [] ⟩
  label-vals :
    (instr : List ty-instr) (n : ty-n) (val : List ty-val) ->
    --------------------------------------------------------------------------------------------------------------------------------
    ty-Step-pure ⟨ (LABEL- n instr ((map (λ val -> ($admininstr-val val))) val)) ∷ [] , (map (λ val -> ($admininstr-val val))) val ⟩
  br-zero :
    (instr : List ty-instr) (instr' : List ty-instr) (n : ty-n) (val : List ty-val) (val' : List ty-val) ->
    (length val) ≡ n ->
    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    ty-Step-pure ⟨ (LABEL- n instr' (((map (λ val' -> ($admininstr-val val'))) val') ++ (((map (λ val -> ($admininstr-val val))) val) ++ (((BR 0) ∷ []) ++ ((map (λ instr -> ($admininstr-instr instr))) instr))))) ∷ [] , ((map (λ val -> ($admininstr-val val))) val) ++ ((map (λ instr' -> ($admininstr-instr instr'))) instr') ⟩
  br-succ :
    (instr : List ty-instr) (instr' : List ty-instr) (l : ty-labelidx) (n : ty-n) (val : List ty-val) ->
    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    ty-Step-pure ⟨ (LABEL- n instr' (((map (λ val -> ($admininstr-val val))) val) ++ (((BR (l + 1)) ∷ []) ++ ((map (λ instr -> ($admininstr-instr instr))) instr)))) ∷ [] , ((map (λ val -> ($admininstr-val val))) val) ++ ((BR l) ∷ []) ⟩
  br-if-true :
    (c : ty-c-numtype) (l : ty-labelidx) ->
    c ≢ 0 ->
    ---------------------------------------------------------------
    ty-Step-pure ⟨ (CONST I32 c) ∷ ((BR-IF l) ∷ []) , (BR l) ∷ [] ⟩
  br-if-false :
    (c : ty-c-numtype) (l : ty-labelidx) ->
    c ≡ 0 ->
    ------------------------------------------------------
    ty-Step-pure ⟨ (CONST I32 c) ∷ ((BR-IF l) ∷ []) , [] ⟩
  frame-vals :
    (f : ty-frame) (n : ty-n) (val : List ty-val) ->
    (length val) ≡ n ->
    ----------------------------------------------------------------------------------------------------------------------------
    ty-Step-pure ⟨ (FRAME- n f ((map (λ val -> ($admininstr-val val))) val)) ∷ [] , (map (λ val -> ($admininstr-val val))) val ⟩
  return-frame :
    (f : ty-frame) (instr : List ty-instr) (n : ty-n) (val : List ty-val) (val' : List ty-val) ->
    (length val) ≡ n ->
    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    ty-Step-pure ⟨ (FRAME- n f (((map (λ val' -> ($admininstr-val val'))) val') ++ (((map (λ val -> ($admininstr-val val))) val) ++ ((RETURN ∷ []) ++ ((map (λ instr -> ($admininstr-instr instr))) instr))))) ∷ [] , (map (λ val -> ($admininstr-val val))) val ⟩
  return-label :
    (instr : List ty-instr) (instr' : List ty-instr) (k : ℕ) (val : List ty-val) ->
    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    ty-Step-pure ⟨ (LABEL- k instr' (((map (λ val -> ($admininstr-val val))) val) ++ ((RETURN ∷ []) ++ ((map (λ instr -> ($admininstr-instr instr))) instr)))) ∷ [] , ((map (λ val -> ($admininstr-val val))) val) ++ (RETURN ∷ []) ⟩
  unop-val :
    (c : ty-c-numtype) (c-1 : ty-c-numtype) (nt : ty-numtype) (unop : ty-unop-numtype) ->
    ($unop ⟨ ⟨ unop , nt ⟩ , c-1 ⟩) ≡ (c ∷ []) ->
    ---------------------------------------------------------------------------
    ty-Step-pure ⟨ (CONST nt c-1) ∷ ((UNOP nt unop) ∷ []) , (CONST nt c) ∷ [] ⟩
  unop-trap :
    (c-1 : ty-c-numtype) (nt : ty-numtype) (unop : ty-unop-numtype) ->
    ($unop ⟨ ⟨ unop , nt ⟩ , c-1 ⟩) ≡ [] ->
    -------------------------------------------------------------------
    ty-Step-pure ⟨ (CONST nt c-1) ∷ ((UNOP nt unop) ∷ []) , TRAP ∷ [] ⟩
  binop-val :
    (binop : ty-binop-numtype) (c : ty-c-numtype) (c-1 : ty-c-numtype) (c-2 : ty-c-numtype) (nt : ty-numtype) ->
    ($binop ⟨ ⟨ ⟨ binop , nt ⟩ , c-1 ⟩ , c-2 ⟩) ≡ (c ∷ []) ->
    ------------------------------------------------------------------------------------------------
    ty-Step-pure ⟨ (CONST nt c-1) ∷ ((CONST nt c-2) ∷ ((BINOP nt binop) ∷ [])) , (CONST nt c) ∷ [] ⟩
  binop-trap :
    (binop : ty-binop-numtype) (c-1 : ty-c-numtype) (c-2 : ty-c-numtype) (nt : ty-numtype) ->
    ($binop ⟨ ⟨ ⟨ binop , nt ⟩ , c-1 ⟩ , c-2 ⟩) ≡ [] ->
    ----------------------------------------------------------------------------------------
    ty-Step-pure ⟨ (CONST nt c-1) ∷ ((CONST nt c-2) ∷ ((BINOP nt binop) ∷ [])) , TRAP ∷ [] ⟩
  testop :
    (c : ty-c-numtype) (c-1 : ty-c-numtype) (nt : ty-numtype) (testop : ty-testop-numtype) ->
    c ≡ ($testop ⟨ ⟨ testop , nt ⟩ , c-1 ⟩) ->
    --------------------------------------------------------------------------------
    ty-Step-pure ⟨ (CONST nt c-1) ∷ ((TESTOP nt testop) ∷ []) , (CONST I32 c) ∷ [] ⟩
  relop :
    (c : ty-c-numtype) (c-1 : ty-c-numtype) (c-2 : ty-c-numtype) (nt : ty-numtype) (relop : ty-relop-numtype) ->
    c ≡ ($relop ⟨ ⟨ ⟨ relop , nt ⟩ , c-1 ⟩ , c-2 ⟩) ->
    -------------------------------------------------------------------------------------------------
    ty-Step-pure ⟨ (CONST nt c-1) ∷ ((CONST nt c-2) ∷ ((RELOP nt relop) ∷ [])) , (CONST I32 c) ∷ [] ⟩
  local-tee :
    (val : ty-val) (x : ty-idx) ->
    --------------------------------------------------------------------------------------------------------------------------------------
    ty-Step-pure ⟨ ($admininstr-val val) ∷ ((LOCAL-TEE x) ∷ []) , ($admininstr-val val) ∷ (($admininstr-val val) ∷ ((LOCAL-SET x) ∷ [])) ⟩

data ty-Step-read : ((ty-config × (List ty-admininstr))) → Set
data ty-Step-read where
  call :
    (x : ty-idx) (z : ty-state) ->
    x < (length ($funcaddr z)) ->
    ----------------------------------------------------------------------------------------------------
    ty-Step-read ⟨ ⟨ z , (CALL x) ∷ [] ⟩ , (CALL-ADDR ((lookup ($funcaddr z)) {!   !} {- idx -})) ∷ [] ⟩
  call-addr :
    (a : ty-addr) (f : ty-frame) (instr : List ty-instr) (k : ℕ) (m : ty-moduleinst) (n : ty-n) (t : List ty-valtype) (t-1 : List ty-valtype) (t-2 : List ty-valtype) (val : List ty-val) (z : ty-state) (o0 : List ty-val) ->
    (length t) ≡ (length o0) ->
    a < (length ($funcinst z)) ->
    (length t-1) ≡ k ->
    (length t-2) ≡ n ->
    (length val) ≡ k ->
    ((Pointwise (λ t -> (λ o0 -> (($default- t) ≡ (just o0))))) t) o0 ->
    ((lookup ($funcinst z)) {!   !} {- idx -}) ≡ ⟨ m , ⟨ ⟨ ⟨ t-1 , t-2 ⟩ , t ⟩ , instr ⟩ ⟩ ->
    f ≡ (record { LOCAL = val ++ o0 ; MODULE = m }) ->
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    ty-Step-read ⟨ ⟨ z , ((map (λ val -> ($admininstr-val val))) val) ++ ((CALL-ADDR a) ∷ []) ⟩ , (FRAME- n f ((LABEL- n [] ((map (λ instr -> ($admininstr-instr instr))) instr)) ∷ [])) ∷ [] ⟩
  local-get :
    (x : ty-idx) (z : ty-state) ->
    ---------------------------------------------------------------------------------------
    ty-Step-read ⟨ ⟨ z , (LOCAL-GET x) ∷ [] ⟩ , ($admininstr-val ($local ⟨ z , x ⟩)) ∷ [] ⟩
  global-get :
    (x : ty-idx) (z : ty-state) ->
    ------------------------------------------------------------------------------------------------
    ty-Step-read ⟨ ⟨ z , (GLOBAL-GET x) ∷ [] ⟩ , ($admininstr-globalinst ($global ⟨ z , x ⟩)) ∷ [] ⟩

data ty-Step : ((ty-config × ty-config)) → Set
data ty-Step where
  pure :
    (instr : List ty-instr) (instr' : List ty-instr) (z : ty-state) ->
    ty-Step-pure ⟨ (map (λ instr -> ($admininstr-instr instr))) instr , (map (λ instr' -> ($admininstr-instr instr'))) instr' ⟩ ->
    --------------------------------------------------------------------------------------------------------------------------------------
    ty-Step ⟨ ⟨ z , (map (λ instr -> ($admininstr-instr instr))) instr ⟩ , ⟨ z , (map (λ instr' -> ($admininstr-instr instr'))) instr' ⟩ ⟩
  read :
    (instr : List ty-instr) (instr' : List ty-instr) (z : ty-state) ->
    ty-Step-read ⟨ ⟨ z , (map (λ instr -> ($admininstr-instr instr))) instr ⟩ , (map (λ instr' -> ($admininstr-instr instr'))) instr' ⟩ ->
    --------------------------------------------------------------------------------------------------------------------------------------
    ty-Step ⟨ ⟨ z , (map (λ instr -> ($admininstr-instr instr))) instr ⟩ , ⟨ z , (map (λ instr' -> ($admininstr-instr instr'))) instr' ⟩ ⟩
  local-set :
    (val : ty-val) (x : ty-idx) (z : ty-state) ->
    -----------------------------------------------------------------------------------------------------------
    ty-Step ⟨ ⟨ z , ($admininstr-val val) ∷ ((LOCAL-SET x) ∷ []) ⟩ , ⟨ $with-local ⟨ ⟨ z , x ⟩ , val ⟩ , [] ⟩ ⟩
  global-set :
    (val : ty-val) (x : ty-idx) (z : ty-state) ->
    -------------------------------------------------------------------------------------------------------------
    ty-Step ⟨ ⟨ z , ($admininstr-val val) ∷ ((GLOBAL-SET x) ∷ []) ⟩ , ⟨ $with-global ⟨ ⟨ z , x ⟩ , val ⟩ , [] ⟩ ⟩
