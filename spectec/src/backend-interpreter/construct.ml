open Reference_interpreter
open Ast
open Types
open Value
open Al.Ast
open Source
open Util.Record


(* Smart Constructor *)

let _nid_count = ref 0
let gen_nid () =
  let nid = !_nid_count in
  _nid_count := nid + 1;
  nid

let mk_node it = { it; nid = gen_nid () }

let ifI (c, il1, il2) = IfI (c, il1, il2) |> mk_node
let eitherI (il1, il2) = EitherI (il1, il2) |> mk_node
let enterI (e1, e2, il) = EnterI (e1, e2, il) |> mk_node
let assertI c = AssertI c |> mk_node
let pushI e = PushI e |> mk_node
let popI e = PopI e |> mk_node
let popallI e = PopAllI e |> mk_node
let letI (e1, e2) = LetI (e1, e2) |> mk_node
let trapI = TrapI |> mk_node
let nopI = NopI |> mk_node
let returnI e_opt = ReturnI e_opt |> mk_node
let executeI e = ExecuteI e |> mk_node
let executeseqI e = ExecuteSeqI e |> mk_node
let performI (id, el) = PerformI (id, el) |> mk_node
let exitI = ExitI |> mk_node
let replaceI (e1, p, e2) = ReplaceI (e1, p, e2) |> mk_node
let appendI (e1, e2) = AppendI (e1, e2) |> mk_node
let otherwiseI il = OtherwiseI il |> mk_node
let yetI s = YetI s |> mk_node

let singleton x = CaseV (x, [])
let listV l = ListV (ref (Array.of_list l))
let id str = VarE str 

let get_name = function
  | RuleA ((name, _), _, _) -> name
  | FuncA (name, _, _) -> name

let get_param = function
  | RuleA (_, params, _) -> params
  | FuncA (_, params, _) -> params

let get_body = function
  | RuleA (_, _, body) -> body
  | FuncA (_, _, body) -> body


(* Construct datastructure *)

let al_of_list f l = List.map f l |> listV

let al_of_opt f opt = OptV (Option.map f opt)

(* Construct integer *)

let al_of_int i = NumV (Int64.of_int i)
let int64_of_int32_u i32 = Int64.of_int32 i32 |> Int64.logand 0x0000_0000_ffff_ffffL
let al_of_int32 i32 = NumV (int64_of_int32_u i32)
let al_of_int64 i64 = NumV i64
let al_of_idx idx = al_of_int32 idx.it


(* Construct type *)

let al_of_null = function
  | NoNull -> CaseV ("NULL", [ OptV None ])
  | Null -> CaseV ("NULL", [ OptV (Some (listV [])) ])

let al_of_final = function
  | NoFinal -> OptV None
  | Final -> OptV (Some (singleton "FINAL"))

let al_of_mut = function
  | Cons -> OptV None
  | Var -> OptV (Some (singleton "MUT"))

let rec al_of_storage_type = function
  | ValStorageT vt -> al_of_val_type vt
  | PackStorageT ps ->
    (Pack.packed_size ps * 8)
    |> string_of_int
    |> Printf.sprintf "I%s"
    |> singleton

and al_of_field_type = function
  | FieldT (mut, st) -> TupV (al_of_mut mut, al_of_storage_type st)

and al_of_result_type rt = al_of_list al_of_val_type rt

and al_of_str_type = function
  | DefStructT (StructT ftl) -> CaseV ("STRUCT", [ al_of_list al_of_field_type ftl ])
  | DefArrayT (ArrayT ft) -> CaseV ("ARRAY", [ al_of_field_type ft ])
  | DefFuncT (FuncT (rt1, rt2)) ->
    CaseV ("FUNC", [ ArrowV (al_of_result_type rt1, al_of_result_type rt2) ])

and al_of_sub_type = function
  | SubT (fin, htl, st) ->
    CaseV ("SUBD", [ al_of_final fin; al_of_list al_of_heap_type htl; al_of_str_type st ])

and al_of_rec_type = function
  | RecT stl -> CaseV ("REC", [ al_of_list al_of_sub_type stl ])

and al_of_def_type = function
  | DefT (rt, i) -> CaseV ("DEF", [al_of_rec_type rt; al_of_int32 i])

and al_of_heap_type = function
  | VarHT (StatX i) -> CaseV ("_IDX", [ al_of_int32 i ])
  | VarHT (RecX i) -> CaseV ("REC", [ al_of_int32 i ])
  | DefHT dt -> al_of_def_type dt
  | BotHT -> singleton "BOT"
  | ht ->
    string_of_heap_type ht
    |> String.uppercase_ascii
    |> singleton

and al_of_ref_type (null, ht) = CaseV ("REF", [ al_of_null null; al_of_heap_type ht ])

and al_of_num_type nt =
  string_of_num_type nt
  |> String.uppercase_ascii
  |> singleton

and al_of_vec_type vt =
  string_of_vec_type vt
  |> String.uppercase_ascii
  |> singleton

and al_of_val_type = function
  | RefT rt -> al_of_ref_type rt
  | NumT nt -> al_of_num_type nt
  | VecT vt -> al_of_vec_type vt
  | BotT -> singleton "BOT"

let al_of_blocktype = function
  | VarBlockType idx -> CaseV ("_IDX", [ NumV (Int64.of_int32 idx.it) ])
  | ValBlockType None -> CaseV ("_RESULT", [ OptV None ])
  | ValBlockType (Some val_type) ->
    CaseV ("_RESULT", [ OptV (Some (al_of_val_type val_type)) ])


(* Construct value *)

let al_of_num = function
  | I32 i -> CaseV ("CONST", [ singleton "I32"; i |> I32.to_bits |> al_of_int32 ])
  | I64 i -> CaseV ("CONST", [ singleton "I64"; i |> I64.to_bits |> al_of_int64 ])
  | F32 f -> CaseV ("CONST", [ singleton "F32"; f |> F32.to_bits |> al_of_int32 ])
  | F64 f -> CaseV ("CONST", [ singleton "F64"; f |> F64.to_bits |> al_of_int64 ])

let rec al_of_ref = function
  | NullRef ht -> CaseV ("REF.NULL", [ al_of_heap_type ht ])
  (*
  | I31.I31Ref i ->
    CaseV ("REF.I31_NUM", [ NumV (Int64.of_int i) ])
  | Aggr.StructRef a ->
    CaseV ("REF.STRUCT_ADDR", [ NumV (int64_of_int32_u a) ])
  | Aggr.ArrayRef a ->
    CaseV ("REF.ARRAY_ADDR", [ NumV (int64_of_int32_u a) ])
  | Instance.FuncRef a ->
    CaseV ("REF.FUNC_ADDR", [ NumV (int64_of_int32_u a) ])
  *)
  | Script.HostRef i32 -> CaseV ("REF.HOST_ADDR", [ al_of_int32 i32 ])
  | Extern.ExternRef r -> CaseV ("REF.EXTERN", [ al_of_ref r ])
  | r -> string_of_ref r |> failwith

let al_of_value = function
  | Num n -> al_of_num n
  | Vec _v -> failwith "TODO"
  | Ref r -> al_of_ref r


(* Construct operation *)

let al_of_op f1 f2 = function
  | I32 op -> [ singleton "I32"; f1 op ]
  | I64 op -> [ singleton "I64"; f1 op ]
  | F32 op -> [ singleton "F32"; f2 op ]
  | F64 op -> [ singleton "F64"; f2 op ]

let al_of_int_unop = function
  | IntOp.Clz -> TextV "Clz"
  | IntOp.Ctz -> TextV "Ctz"
  | IntOp.Popcnt -> TextV "Popcnt"
  | IntOp.ExtendS Pack.Pack8 -> TextV "Extend8S"
  | IntOp.ExtendS Pack.Pack16 -> TextV "Extend16S"
  | IntOp.ExtendS Pack.Pack32 -> TextV "Extend32S"
  | IntOp.ExtendS Pack.Pack64 -> TextV "Extend64S"
let al_of_float_unop = function
  | FloatOp.Neg -> TextV "Neg"
  | FloatOp.Abs -> TextV "Abs"
  | FloatOp.Ceil -> TextV "Ceil"
  | FloatOp.Floor -> TextV "Floor"
  | FloatOp.Trunc -> TextV "Trunc"
  | FloatOp.Nearest -> TextV "Nearest"
  | FloatOp.Sqrt -> TextV "Sqrt"
let al_of_unop = al_of_op al_of_int_unop al_of_float_unop

let al_of_int_binop = function
  | IntOp.Add -> TextV "Add"
  | IntOp.Sub -> TextV "Sub"
  | IntOp.Mul -> TextV "Mul"
  | IntOp.DivS -> TextV "DivS"
  | IntOp.DivU -> TextV "DivU"
  | IntOp.RemS -> TextV "RemS"
  | IntOp.RemU -> TextV "RemU"
  | IntOp.And -> TextV "And"
  | IntOp.Or -> TextV "Or"
  | IntOp.Xor -> TextV "Xor"
  | IntOp.Shl -> TextV "Shl"
  | IntOp.ShrS -> TextV "ShrS"
  | IntOp.ShrU -> TextV "ShrU"
  | IntOp.Rotl -> TextV "Rotl"
  | IntOp.Rotr -> TextV "Rotr"
let al_of_float_binop = function
  | FloatOp.Add -> TextV "Add"
  | FloatOp.Sub -> TextV "Sub"
  | FloatOp.Mul -> TextV "Mul"
  | FloatOp.Div -> TextV "Div"
  | FloatOp.Min -> TextV "Min"
  | FloatOp.Max -> TextV "Max"
  | FloatOp.CopySign -> TextV "CopySign"
let al_of_binop = al_of_op al_of_int_binop al_of_float_binop

let al_of_int_testop = function
  | IntOp.Eqz -> TextV "Eqz"
let al_of_testop: testop -> value list = function
  | I32 op -> [ singleton "I32"; al_of_int_testop op ]
  | I64 op -> [ singleton "I64"; al_of_int_testop op ]
  | _ -> .

let al_of_int_relop = function
  | IntOp.Eq -> TextV "Eq"
  | IntOp.Ne -> TextV "Ne"
  | IntOp.LtS -> TextV "LtS"
  | IntOp.LtU -> TextV "LtU"
  | IntOp.GtS -> TextV "GtS"
  | IntOp.GtU -> TextV "GtU"
  | IntOp.LeS -> TextV "LeS"
  | IntOp.LeU -> TextV "LeU"
  | IntOp.GeS -> TextV "GeS"
  | IntOp.GeU -> TextV "GeU"
let al_of_float_relop = function
  | FloatOp.Eq -> TextV "Eq"
  | FloatOp.Ne -> TextV "Ne"
  | FloatOp.Lt -> TextV "Lt"
  | FloatOp.Gt -> TextV "Gt"
  | FloatOp.Le -> TextV "Le"
  | FloatOp.Ge -> TextV "Ge"
let al_of_relop = al_of_op al_of_int_relop al_of_float_relop

let al_of_int_cvtop num_bits = function
  | IntOp.ExtendSI32 -> "Extend", "I32", Some (singleton "S")
  | IntOp.ExtendUI32 -> "Extend", "I32", Some (singleton "U")
  | IntOp.WrapI64 -> "Wrap", "I64", None
  | IntOp.TruncSF32 -> "Trunc", "F32", Some (singleton "S")
  | IntOp.TruncUF32 -> "Trunc", "F32", Some (singleton "U")
  | IntOp.TruncSF64 -> "Trunc", "F64", Some (singleton "S")
  | IntOp.TruncUF64 -> "Trunc", "F64", Some (singleton "U")
  | IntOp.TruncSatSF32 -> "TruncSat", "F32", Some (singleton "S")
  | IntOp.TruncSatUF32 -> "TruncSat", "F32", Some (singleton "U")
  | IntOp.TruncSatSF64 -> "TruncSat", "F64", Some (singleton "S")
  | IntOp.TruncSatUF64 -> "TruncSat", "F64", Some (singleton "U")
  | IntOp.ReinterpretFloat -> "Reinterpret", "F" ^ num_bits, None
let al_of_float_cvtop num_bits = function
  | FloatOp.ConvertSI32 -> "Convert", "I32", Some (singleton ("S"))
  | FloatOp.ConvertUI32 -> "Convert", "I32", Some (singleton ("U"))
  | FloatOp.ConvertSI64 -> "Convert", "I64", Some (singleton ("S"))
  | FloatOp.ConvertUI64 -> "Convert", "I64", Some (singleton ("U"))
  | FloatOp.PromoteF32 -> "Promote", "F32", None
  | FloatOp.DemoteF64 -> "Demote", "F64", None
  | FloatOp.ReinterpretInt -> "Reinterpret", "I" ^ num_bits, None
let al_of_cvtop = function
  | I32 op ->
    let op', to_, sx = al_of_int_cvtop "32" op in
    [ singleton "I32"; TextV op'; singleton to_; OptV sx ]
  | I64 op ->
    let op', to_, sx = al_of_int_cvtop "64" op in
    [ singleton "I64"; TextV op'; singleton to_; OptV sx ]
  | F32 op ->
    let op', to_, sx = al_of_float_cvtop "32" op in
    [ singleton "F32"; TextV op'; singleton to_; OptV sx ]
  | F64 op ->
    let op', to_, sx = al_of_float_cvtop "64" op in
    [ singleton "F64"; TextV op'; singleton to_; OptV sx ]

let al_of_pack_size = function
  | Pack.Pack8 -> NumV (Int64.of_int 8)
  | Pack.Pack16 -> NumV (Int64.of_int 16)
  | Pack.Pack32 -> NumV (Int64.of_int 32)
  | Pack.Pack64 -> NumV (Int64.of_int 64)

let al_of_extension = function
  | Pack.SX -> singleton "S"
  | Pack.ZX -> singleton "U"

let al_of_memop al_of_pack memop =
  let str =
    Record.empty
    |> Record.add "ALIGN" (al_of_int memop.align)
    |> Record.add "OFFSET" (al_of_int32 memop.offset)
  in
  [
    al_of_num_type memop.ty;
    al_of_opt al_of_pack memop.pack;
    NumV 0L;
    StrV str;
  ]

let al_of_pack_size_extension (p, s) = listV [ al_of_pack_size p; al_of_extension s ]

let al_of_loadop = al_of_memop al_of_pack_size_extension

let al_of_storeop = al_of_memop al_of_pack_size


(* Construct instruction *)

let rec al_of_instr winstr =
  match winstr.it with
  (* wasm values *)
  | Const num -> al_of_num num.it
  | RefNull ht -> CaseV ("REF.NULL", [ al_of_heap_type ht ])
  (* wasm instructions *)
  | Unreachable -> singleton "UNREACHABLE"
  | Nop -> singleton "NOP"
  | Drop -> singleton "DROP"
  | Unary op -> CaseV ("UNOP", al_of_unop op)
  | Binary op -> CaseV ("BINOP", al_of_binop op)
  | Test op -> CaseV ("TESTOP", al_of_testop op)
  | Compare op -> CaseV ("RELOP", al_of_relop op)
  | Convert op -> CaseV ("CVTOP", al_of_cvtop op)
  | RefIsNull -> singleton "REF.IS_NULL"
  | RefFunc idx -> CaseV ("REF.FUNC", [ al_of_idx idx ])
  | Select None -> CaseV ("SELECT", [ OptV None ])
  | Select (Some ts) -> CaseV ("SELECT", [ OptV (Some (al_of_list al_of_val_type ts)) ])
  | LocalGet idx -> CaseV ("LOCAL.GET", [ al_of_idx idx ])
  | LocalSet idx -> CaseV ("LOCAL.SET", [ al_of_idx idx ])
  | LocalTee idx -> CaseV ("LOCAL.TEE", [ al_of_idx idx ])
  | GlobalGet idx -> CaseV ("GLOBAL.GET", [ al_of_idx idx ])
  | GlobalSet idx -> CaseV ("GLOBAL.SET", [ al_of_idx idx ])
  | TableGet idx -> CaseV ("TABLE.GET", [ al_of_idx idx ])
  | TableSet idx -> CaseV ("TABLE.SET", [ al_of_idx idx ])
  | TableSize idx -> CaseV ("TABLE.SIZE", [ al_of_idx idx ])
  | TableGrow idx -> CaseV ("TABLE.GROW", [ al_of_idx idx ])
  | TableFill idx -> CaseV ("TABLE.FILL", [ al_of_idx idx ])
  | TableCopy (idx1, idx2) -> CaseV ("TABLE.COPY", [ al_of_idx idx1; al_of_idx idx2 ])
  | TableInit (idx1, idx2) -> CaseV ("TABLE.INIT", [ al_of_idx idx1; al_of_idx idx2 ])
  | ElemDrop idx -> CaseV ("ELEM.DROP", [ al_of_idx idx ])
  | Block (bt, instrs) ->
    CaseV ("BLOCK", [ al_of_blocktype bt; al_of_list al_of_instr instrs ])
  | Loop (bt, instrs) ->
    CaseV ("LOOP", [ al_of_blocktype bt; al_of_list al_of_instr instrs ])
  | If (bt, instrs1, instrs2) ->
    CaseV ("IF", [
      al_of_blocktype bt;
      al_of_list al_of_instr instrs1;
      al_of_list al_of_instr instrs2;
    ])
  | Br idx -> CaseV ("BR", [ al_of_idx idx ])
  | BrIf idx -> CaseV ("BR_IF", [ al_of_idx idx ])
  | BrTable (idxs, idx) ->
    CaseV ("BR_TABLE", [ al_of_list al_of_idx idxs; al_of_idx idx ])
  | BrOnNull idx -> CaseV ("BR_ON_NULL", [ al_of_idx idx ])
  | BrOnNonNull idx -> CaseV ("BR_ON_NON_NULL", [ al_of_idx idx ])
  | BrOnCast (idx, rt1, rt2) ->
    CaseV ("BR_ON_CAST", [ al_of_idx idx; al_of_ref_type rt1; al_of_ref_type rt2 ])
  | BrOnCastFail (idx, rt1, rt2) ->
    CaseV ("BR_ON_CAST_FAIL", [ al_of_idx idx; al_of_ref_type rt1; al_of_ref_type rt2 ])
  | Return -> singleton "RETURN"
  | Call idx -> CaseV ("CALL", [ al_of_idx idx ])
  | CallRef idx -> CaseV ("CALL_REF", [ OptV (Some (al_of_idx idx)) ])
  | CallIndirect (idx1, idx2) ->
    CaseV ("CALL_INDIRECT", [ al_of_idx idx1; al_of_idx idx2 ])
  | ReturnCall idx -> CaseV ("RETURN_CALL", [ al_of_idx idx ])
  | ReturnCallRef idx -> CaseV ("RETURN_CALL_REF", [ OptV (Some (al_of_idx idx)) ])
  | ReturnCallIndirect (idx1, idx2) ->
    CaseV ("RETURN_CALL_INDIRECT", [ al_of_idx idx1; al_of_idx idx2 ])
  | Load loadop -> CaseV ("LOAD", al_of_loadop loadop)
  | Store storeop -> CaseV ("STORE", al_of_storeop storeop)
  | MemorySize -> CaseV ("MEMORY.SIZE", [ NumV 0L ])
  | MemoryGrow -> CaseV ("MEMORY.GROW", [ NumV 0L ])
  | MemoryFill -> CaseV ("MEMORY.FILL", [ NumV 0L ])
  | MemoryCopy -> CaseV ("MEMORY.COPY", [ NumV 0L; NumV 0L ])
  | MemoryInit i32 -> CaseV ("MEMORY.INIT", [ NumV 0L; al_of_idx i32 ])
  | DataDrop idx -> CaseV ("DATA.DROP", [ al_of_idx idx ])
  | RefAsNonNull -> singleton "REF.AS_NON_NULL"
  | RefTest rt -> CaseV ("REF.TEST", [ al_of_ref_type rt ])
  | RefCast rt -> CaseV ("REF.CAST", [ al_of_ref_type rt ])
  | RefEq -> singleton "REF.EQ"
  | RefI31 -> singleton "REF.I31"
  | I31Get sx -> CaseV ("I31.GET", [ al_of_extension sx ])
  | StructNew (idx, Explicit) -> CaseV ("STRUCT.NEW", [ al_of_idx idx ])
  | StructNew (idx, Implicit) -> CaseV ("STRUCT.NEW_DEFAULT", [ al_of_idx idx ])
  | StructGet (idx1, idx2, sx_opt) ->
    CaseV ("STRUCT.GET", [
      al_of_opt al_of_extension sx_opt;
      al_of_idx idx1;
      al_of_idx idx2;
    ])
  | StructSet (idx1, idx2) -> CaseV ("STRUCT.SET", [ al_of_idx idx1; al_of_idx idx2 ])
  | ArrayNew (idx, Explicit) -> CaseV ("ARRAY.NEW", [ al_of_idx idx ])
  | ArrayNew (idx, Implicit) -> CaseV ("ARRAY.NEW_DEFAULT", [ al_of_idx idx ])
  | ArrayNewFixed (idx, i32) ->
    CaseV ("ARRAY.NEW_FIXED", [ al_of_idx idx; al_of_int32 i32 ])
  | ArrayNewElem (idx1, idx2) ->
    CaseV ("ARRAY.NEW_ELEM", [ al_of_idx idx1; al_of_idx idx2 ])
  | ArrayNewData (idx1, idx2) ->
    CaseV ("ARRAY.NEW_DATA", [ al_of_idx idx1; al_of_idx idx2 ])
  | ArrayGet (idx, sx_opt) ->
    CaseV ("ARRAY.GET", [ al_of_opt al_of_extension sx_opt; al_of_idx idx ])
  | ArraySet idx -> CaseV ("ARRAY.SET", [ al_of_idx idx ])
  | ArrayLen -> singleton "ARRAY.LEN"
  | ArrayCopy (idx1, idx2) -> CaseV ("ARRAY.COPY", [ al_of_idx idx1; al_of_idx idx2 ])
  | ArrayFill idx -> CaseV ("ARRAY.FILL", [ al_of_idx idx ])
  | ArrayInitData (idx1, idx2) ->
    CaseV ("ARRAY.INIT_DATA", [ al_of_idx idx1; al_of_idx idx2 ])
  | ArrayInitElem (idx1, idx2) ->
    CaseV ("ARRAY.INIT_ELEM", [ al_of_idx idx1; al_of_idx idx2 ])
  | ExternConvert Internalize -> singleton "ANY.CONVERT_EXTERN"
  | ExternConvert Externalize -> singleton "EXTERN.CONVERT_ANY"
  | _ -> CaseV ("TODO: Unconstructed Wasm instruction (al_of_instr)", [])

(* Construct module *)

let al_of_local l = CaseV ("LOCAL", [ al_of_val_type l.it.ltype ])

let al_of_func wasm_func =
  CaseV ("FUNC", [
    al_of_int32 wasm_func.it.ftype.it;
    al_of_list al_of_local wasm_func.it.locals;
    al_of_list al_of_instr wasm_func.it.body;
  ])

let al_of_global wasm_global =
  CaseV ("GLOBAL", [
    TextV "Yet: global type";
    al_of_list al_of_instr wasm_global.it.ginit.it
  ])

let al_of_limits limits default =
  let max =
    match limits.max with
    | Some v -> al_of_int32 v
    | None -> al_of_int64 default
  in

  TupV (al_of_int32 limits.min, max)

let al_of_table wasm_table =

  let TableT (limits, ref_ty) = wasm_table.it.ttype in
  let pair = al_of_limits limits 4294967295L in

  let expr = al_of_list al_of_instr wasm_table.it.tinit.it in

  CaseV ("TABLE", [ TupV(pair, al_of_val_type (RefT ref_ty)); expr ])

let al_of_memory wasm_memory =
  let MemoryT (limits) = wasm_memory.it.mtype in
  let pair = al_of_limits limits 65536L in

  CaseV ("MEMORY", [ CaseV ("I8", [ pair]) ])

let al_of_segment wasm_segment = match wasm_segment.it with
  | Passive -> singleton "PASSIVE"
  | Active { index = index; offset = offset } ->
      CaseV (
        "ACTIVE",
        [
          NumV (int64_of_int32_u index.it);
          al_of_list al_of_instr offset.it
        ]
      )
  | Declarative -> singleton "DECLARE"

let al_of_elem wasm_elem =
  let reftype = al_of_val_type (RefT wasm_elem.it.etype) in

  let al_of_const const = al_of_list al_of_instr const.it in
  let instrs = al_of_list al_of_const wasm_elem.it.einit in

  let mode = al_of_segment wasm_elem.it.emode in

  CaseV ("ELEM", [ reftype; instrs; mode ])

let al_of_data wasm_data =
  (* TODO: byte list list *)
  let init = wasm_data.it.dinit in

  let f chr acc = NumV (Int64.of_int (Char.code chr)) :: acc in
  let byte_list = String.fold_right f init [] in

  let mode = al_of_segment wasm_data.it.dmode in

  CaseV ("DATA", [ listV byte_list; mode ])

let al_of_import_desc wasm_module idesc = match idesc.it with
  | FuncImport x ->
      let dts = def_types_of wasm_module in
      let dt = Lib.List32.nth dts x.it |> al_of_def_type in
      CaseV ("FUNC", [ dt ])
  | TableImport ty ->
    let TableT (limits, ref_ty) = ty in
    let pair = al_of_limits limits 4294967295L in
    CaseV ("TABLE", [ pair; al_of_val_type (RefT ref_ty) ])
  | MemoryImport ty ->
    let MemoryT (limits) = ty in
    let pair = al_of_limits limits 65536L in
    CaseV ("MEM", [ pair ])
  | GlobalImport _ -> CaseV ("GLOBAL", [ TextV "Yet: global type" ])

let al_of_import wasm_module wasm_import =

  let module_name = TextV (wasm_import.it.module_name |> Utf8.encode) in
  let item_name = TextV (wasm_import.it.item_name |> Utf8.encode) in

  let import_desc = al_of_import_desc wasm_module wasm_import.it.idesc in

  CaseV ("IMPORT", [ module_name; item_name; import_desc ])

let al_of_export_desc export_desc = match export_desc.it with
  | FuncExport n -> CaseV ("FUNC", [ NumV (int64_of_int32_u n.it) ])
  | TableExport n -> CaseV ("TABLE", [ NumV (int64_of_int32_u n.it) ])
  | MemoryExport n -> CaseV ("MEM", [ NumV (int64_of_int32_u n.it) ])
  | GlobalExport n -> CaseV ("GLOBAL", [ NumV (int64_of_int32_u n.it) ])

let al_of_start wasm_start =
  CaseV ("START", [ NumV (int64_of_int32_u wasm_start.it.sfunc.it) ])

let al_of_export wasm_export =

  let name = TextV (wasm_export.it.name |> Utf8.encode) in
  let export_desc = al_of_export_desc wasm_export.it.edesc in

  CaseV ("EXPORT", [ name; export_desc ])

let al_of_module wasm_module =

  (* Construct types *)
  let type_list =
    List.map (fun ty ->
      CaseV ("TYPE", [ al_of_rec_type ty.it ])
    ) wasm_module.it.types
  in

  (* Construct imports *)
  let import_list =
    List.map (al_of_import wasm_module) wasm_module.it.imports
  in

  (* Construct functions *)
  let func_list =
    List.map al_of_func wasm_module.it.funcs
  in

  (* Construct global *)
  let global_list =
    List.map al_of_global wasm_module.it.globals
  in

  (* Construct table *)
  let table_list =
    List.map al_of_table wasm_module.it.tables
  in

  (* Construct memory *)
  let memory_list =
    List.map al_of_memory wasm_module.it.memories
  in

  (* Construct elem *)
  let elem_list =
    List.map al_of_elem wasm_module.it.elems
  in

  (* Construct data *)
  let data_list =
    List.map al_of_data wasm_module.it.datas
  in

  (* Construct start *)
  let start_opt =
    al_of_opt al_of_start wasm_module.it.start
  in

  (* Construct export *)
  let export_list =
    List.map al_of_export wasm_module.it.exports
  in

  CaseV (
    "MODULE",
    [
      listV type_list;
      listV import_list;
      listV func_list;
      listV global_list;
      listV table_list;
      listV memory_list;
      listV elem_list;
      listV data_list;
      start_opt;
      listV export_list
    ]
  )

let fail ty v =
  Al.Print.string_of_value v
  |> Printf.sprintf "Invalid %s: %s" ty
  |> failwith

let al_to_idx: value -> Ast.idx = function
  | NumV i -> Int64.to_int32 i @@ no_region
  | v -> fail "idx" v

open Types

(* Deconstruct type *)

let al_to_null: value -> null = function
  | CaseV ("NULL", [ OptV None ]) -> NoNull
  | CaseV ("NULL", [ OptV _ ]) -> Null
  | v -> fail "null" v

let al_to_final: value -> final = function
  | OptV None -> NoFinal
  | OptV (Some (CaseV ("FINAL", []))) -> Final
  | v -> fail "final" v

let al_to_mut: value -> mut = function
  | OptV None -> Cons
  | OptV (Some (CaseV ("MUT", []))) -> Var
  | v -> fail "mut" v

let rec al_to_storage_type: value -> storage_type = function
  | CaseV ("I8", []) -> PackStorageT Pack8
  | CaseV ("I16", []) -> PackStorageT Pack16
  | v -> ValStorageT (al_to_val_type v)

and al_to_field_type: value -> field_type = function
  | TupV (mut, st) ->
    FieldT (al_to_mut mut, al_to_storage_type st)
  | v -> fail "field type" v

and al_to_result_type: value -> result_type = function
  | ListV vtl ->
    let vtl' = Array.to_list !vtl in
    List.map al_to_val_type vtl'
  | v -> fail "result type" v

and al_to_str_type: value -> str_type = function
  | CaseV ("STRUCT", [ ListV ftl ]) ->
    let ftl' = Array.to_list !ftl in
    DefStructT (StructT (List.map al_to_field_type ftl'))
  | CaseV ("ARRAY", [ ft ]) ->
    DefArrayT (ArrayT (al_to_field_type ft))
  | CaseV ("FUNC", [ ArrowV (rt1, rt2) ]) ->
    DefFuncT (FuncT (al_to_result_type rt1, (al_to_result_type rt2)))
  | v -> fail "str type" v

and al_to_sub_type: value -> sub_type = function
  | CaseV ("SUBD", [ fin; ListV htl; st ]) ->
    let htl' = Array.to_list !htl in
    SubT (
      al_to_final fin,
      List.map al_to_heap_type htl',
      al_to_str_type st
    )
  | v -> fail "sub type" v

and al_to_rec_type: value -> rec_type = function
  | CaseV ("REC", [ ListV stl ]) ->
    let stl' = Array.to_list !stl in
    RecT (List.map al_to_sub_type stl')
  | v -> fail "rec type" v

and al_to_def_type: value -> def_type = function
  | CaseV ("DEF", [ rt; NumV i ]) ->
    DefT (al_to_rec_type rt, Int64.to_int32 i)
  | v -> fail "def type" v

and al_to_heap_type: value -> heap_type = function
  | CaseV ("_IDX", [ NumV i ]) ->
    VarHT (StatX (Int64.to_int32 i))
  | CaseV ("REC", [ NumV i ]) ->
    VarHT (RecX (Int64.to_int32 i))
  | CaseV ("DEF", _) as v ->
    DefHT (al_to_def_type v)
  | CaseV (tag, []) as v ->
    begin match tag with
    | "BOT" -> BotHT
    | "ANY" -> AnyHT
    | "NONE" -> NoneHT
    | "EQ" -> EqHT
    | "I31" -> I31HT
    | "STRUCT" -> StructHT
    | "ARRAY" -> ArrayHT
    | "FUNC" -> FuncHT
    | "NOFUNC" -> NoFuncHT
    | "EXTERN" -> ExternHT
    | "NOEXTERN" -> NoExternHT
    | _ -> fail "abstract heap type" v
    end
  | v -> fail "heap type" v

and al_to_ref_type: value -> ref_type = function
  | CaseV ("REF", [ n; ht ]) ->
    al_to_null n, al_to_heap_type ht
  | v -> fail "ref type" v

and al_to_val_type: value -> val_type = function
  | CaseV ("I32", []) -> NumT I32T
  | CaseV ("I64", []) -> NumT I64T
  | CaseV ("F32", []) -> NumT F32T
  | CaseV ("F64", []) -> NumT F64T
  | CaseV ("V128", []) -> VecT V128T
  | CaseV ("REF", _) as v ->
    RefT (al_to_ref_type v)
  | CaseV ("BOT", []) -> BotT
  | v -> fail "val type" v

(* Deconstruct value *)

open Value
open Al.Ast

let al_to_num: value -> Value.num = function
  | CaseV (_, [ CaseV ("I32", []); NumV i ]) -> I32 (Int64.to_int32 i)
  | CaseV (_, [ CaseV ("I64", []); NumV i ]) -> I64 i
  | CaseV (_, [ CaseV ("F32", []); NumV i ]) ->
    let f32 = Int64.to_int32 i |> F32.of_bits in
    F32 f32
  | CaseV (_, [ CaseV ("F64", []); NumV i ]) -> F64 (F64.of_bits i)
  | v -> fail "num" v

let rec al_to_ref: value -> Value.ref_ = function
  | CaseV ("REF.NULL", [ ht ]) -> NullRef (al_to_heap_type ht)
  | CaseV ("REF.HOST_ADDR", [ NumV i ]) -> Script.HostRef (Int64.to_int32 i)
  | CaseV ("REF.EXTERN", [ r ]) -> Extern.ExternRef (al_to_ref r)
  | v -> fail "ref" v

let al_to_value: value -> Value.value = function
  | CaseV ("CONST", _) as v -> Num (al_to_num v)
  | CaseV (ref, _) as v when String.starts_with ~prefix:"REF." ref ->
    Ref (al_to_ref v)
  | v -> fail "value" v

(* Deconstruct block type *)

open Ast

let al_to_block_type: value -> block_type = function
  | CaseV ("_IDX", [ idx ]) -> VarBlockType (al_to_idx idx)
  | CaseV ("_RESULT", [ OptV None ]) -> ValBlockType None
  | CaseV ("_RESULT", [ OptV (Some (val_type)) ]) -> ValBlockType (Some (al_to_val_type val_type))
  | v -> fail "block type" v

(* Deconstruct operator *)

let al_to_op f1 f2 = function
  | [ CaseV ("I32", []); op ] -> Value.I32 (f1 op)
  | [ CaseV ("I64", []); op ] -> Value.I64 (f1 op)
  | [ CaseV ("F32", []); op ] -> Value.F32 (f2 op)
  | [ CaseV ("F64", []); op ] -> Value.F64 (f2 op)
  | v -> fail "op" (listV v)

let al_to_int_unop: value -> IntOp.unop = function
  | TextV "Clz" -> IntOp.Clz
  | TextV "Ctz" -> IntOp.Ctz
  | TextV "Popcnt" -> IntOp.Popcnt
  | TextV "Extend8S" -> IntOp.ExtendS Pack.Pack8
  | TextV "Extend16S" -> IntOp.ExtendS Pack.Pack16
  | TextV "Extend32S" -> IntOp.ExtendS Pack.Pack32
  | TextV "Extend64S" -> IntOp.ExtendS Pack.Pack64
  | v -> fail "integer unop" v
let al_to_float_unop: value -> FloatOp.unop = function
  | TextV "Neg" -> FloatOp.Neg
  | TextV "Abs" -> FloatOp.Abs
  | TextV "Ceil" -> FloatOp.Ceil
  | TextV "Floor" -> FloatOp.Floor
  | TextV "Trunc" -> FloatOp.Trunc
  | TextV "Nearest" -> FloatOp.Nearest
  | TextV "Sqrt" -> FloatOp.Sqrt
  | v -> fail "float unop" v
let al_to_unop: value list -> Ast.unop = al_to_op al_to_int_unop al_to_float_unop

let al_to_int_binop: value -> IntOp.binop = function
  | TextV "Add" -> IntOp.Add
  | TextV "Sub" -> IntOp.Sub
  | TextV "Mul" -> IntOp.Mul
  | TextV "DivS" -> IntOp.DivS
  | TextV "DivU" -> IntOp.DivU
  | TextV "RemS" -> IntOp.RemS
  | TextV "RemU" -> IntOp.RemU
  | TextV "And" -> IntOp.And
  | TextV "Or" -> IntOp.Or
  | TextV "Xor" -> IntOp.Xor
  | TextV "Shl" -> IntOp.Shl
  | TextV "ShrS" -> IntOp.ShrS
  | TextV "ShrU" -> IntOp.ShrU
  | TextV "Rotl" -> IntOp.Rotl
  | v -> fail "integer binop" v
let al_to_float_binop: value -> FloatOp.binop = function
  | TextV "Add" -> FloatOp.Add
  | TextV "Sub" -> FloatOp.Sub
  | TextV "Mul" -> FloatOp.Mul
  | TextV "Div" -> FloatOp.Div
  | TextV "Min" -> FloatOp.Min
  | TextV "Max" -> FloatOp.Max
  | TextV "CopySign" -> FloatOp.CopySign
  | v -> fail "float binop" v
let al_to_binop: value list -> Ast.binop = al_to_op al_to_int_binop al_to_float_binop

let al_to_int_testop: value -> IntOp.testop = function
  | TextV "Eqz" -> Ast.IntOp.Eqz
  | v -> fail "integer testop" v
let al_to_testop: value list -> Ast.testop = function
  | [ CaseV ("I32", []); op ] -> Value.I32 (al_to_int_testop op)
  | [ CaseV ("I64", []); op ] -> Value.I64 (al_to_int_testop op)
  | v -> fail "testop" (listV v)

let al_to_int_relop: value -> IntOp.relop = function
  | TextV "Eq" -> Ast.IntOp.Eq
  | TextV "Ne" -> Ast.IntOp.Ne
  | TextV "LtS" -> Ast.IntOp.LtS
  | TextV "LtU" -> Ast.IntOp.LtU
  | TextV "GtS" -> Ast.IntOp.GtS
  | TextV "GtU" -> Ast.IntOp.GtU
  | TextV "LeS" -> Ast.IntOp.LeS
  | TextV "LeU" -> Ast.IntOp.LeU
  | TextV "GeS" -> Ast.IntOp.GeS
  | TextV "GeU" -> Ast.IntOp.GeU
  | v -> fail "integer relop" v
let al_to_float_relop: value -> FloatOp.relop = function
  | TextV "Eq" -> Ast.FloatOp.Eq
  | TextV "Ne" -> Ast.FloatOp.Ne
  | TextV "Lt" -> Ast.FloatOp.Lt
  | TextV "Gt" -> Ast.FloatOp.Gt
  | TextV "Le" -> Ast.FloatOp.Le
  | TextV "Ge" -> Ast.FloatOp.Ge
  | v -> fail "float relop" v
let al_to_relop: value list -> Ast.relop = al_to_op al_to_int_relop al_to_float_relop

let al_to_int_cvtop: value list -> IntOp.cvtop = function
  | [ TextV "Extend"; CaseV ("I32", []); OptV (Some (CaseV ("S", []))) ] -> Ast.IntOp.ExtendSI32
  | [ TextV "Extend"; CaseV ("I32", []); OptV (Some (CaseV ("U", []))) ] -> Ast.IntOp.ExtendUI32
  | [ TextV "Wrap"; CaseV ("I64", []); OptV None ] -> Ast.IntOp.WrapI64
  | [ TextV "Trunc"; CaseV ("F32", []); OptV (Some (CaseV ("S", []))) ] -> Ast.IntOp.TruncSF32
  | [ TextV "Trunc"; CaseV ("F32", []); OptV (Some (CaseV ("U", []))) ] -> Ast.IntOp.TruncUF32
  | [ TextV "Trunc"; CaseV ("F64", []); OptV (Some (CaseV ("S", []))) ] -> Ast.IntOp.TruncSF64
  | [ TextV "Trunc"; CaseV ("F64", []); OptV (Some (CaseV ("U", []))) ] -> Ast.IntOp.TruncUF64
  | [ TextV "TruncSat"; CaseV ("F32", []); OptV (Some (CaseV ("S", []))) ] -> Ast.IntOp.TruncSatSF32
  | [ TextV "TruncSat"; CaseV ("F32", []); OptV (Some (CaseV ("U", []))) ] -> Ast.IntOp.TruncSatUF32
  | [ TextV "TruncSat"; CaseV ("F64", []); OptV (Some (CaseV ("S", []))) ] -> Ast.IntOp.TruncSatSF64
  | [ TextV "TruncSat"; CaseV ("F64", []); OptV (Some (CaseV ("U", []))) ] -> Ast.IntOp.TruncSatUF64
  | [ TextV "Reinterpret"; _; OptV None ] -> Ast.IntOp.ReinterpretFloat
  | v -> fail "integer cvtop" (listV v)
let al_to_float_cvtop : value list -> FloatOp.cvtop = function
  | [ TextV "Convert"; CaseV ("I32", []); OptV (Some (CaseV (("S", [])))) ] -> Ast.FloatOp.ConvertSI32
  | [ TextV "Convert"; CaseV ("I32", []); OptV (Some (CaseV (("U", [])))) ] -> Ast.FloatOp.ConvertUI32
  | [ TextV "Convert"; CaseV ("I64", []); OptV (Some (CaseV (("S", [])))) ] -> Ast.FloatOp.ConvertSI64
  | [ TextV "Convert"; CaseV ("I64", []); OptV (Some (CaseV (("U", [])))) ] -> Ast.FloatOp.ConvertUI64
  | [ TextV "Promote"; CaseV ("F32", []); OptV None ] -> Ast.FloatOp.PromoteF32
  | [ TextV "Demote"; CaseV ("F64", []); OptV None ] -> Ast.FloatOp.DemoteF64
  | [ TextV "Reinterpret"; _; OptV None ] -> Ast.FloatOp.ReinterpretInt
  | v -> fail "float cvtop" (listV v)
let al_to_cvtop: value list -> Ast.cvtop = function
  | CaseV ("I32", []) :: op -> Value.I32 (al_to_int_cvtop op)
  | CaseV ("I64", []) :: op -> Value.I64 (al_to_int_cvtop op)
  | CaseV ("F32", []) :: op -> Value.F32 (al_to_float_cvtop op)
  | CaseV ("F64", []) :: op -> Value.F64 (al_to_float_cvtop op)
  | v -> fail "cvtop" (listV v)

let al_to_pack_size: value -> Pack.pack_size = function
  | NumV 8L -> Pack.Pack8
  | NumV 16L -> Pack.Pack16
  | NumV 32L -> Pack.Pack32
  | NumV 64L -> Pack.Pack64
  | v -> fail "pack_size" v

let al_to_extension: value -> Pack.extension = function
  | CaseV ("S", []) -> Pack.SX
  | CaseV ("U", []) -> Pack.ZX
  | v -> fail "extension" v

let al_to_pack_size_with_extension (_p, _s) = failwith "TODO"

let rec al_to_instr (v: value): Ast.instr = al_to_instr' v @@ no_region
and al_to_instr': value -> Ast.instr' = function
  (* wasm values *)
  | CaseV ("CONST", _) as v -> Ast.Const (al_to_num v @@ no_region)
  | CaseV ("REF.NULL", [ ht ]) -> Ast.RefNull (al_to_heap_type ht)
  (* wasm instructions *)
  | CaseV ("UNREACHABLE", []) -> Ast.Unreachable
  | CaseV ("NOP", []) -> Ast.Nop
  | CaseV ("DROP", []) -> Ast.Drop
  | CaseV ("UNOP", op) -> Ast.Unary (al_to_unop op)
  | CaseV ("BINOP", op) -> Ast.Binary (al_to_binop op)
  | CaseV ("TESTOP", op) -> Ast.Test (al_to_testop op)
  | CaseV ("RELOP", op) -> Ast.Compare (al_to_relop op)
  | CaseV ("CVTOP", op) -> Ast.Convert (al_to_cvtop op)
  | CaseV ("REF.IS_NULL", []) -> Ast.RefIsNull
  | CaseV ("REF.FUNC", [ idx ]) -> Ast.RefFunc (al_to_idx idx)
  | CaseV ("SELECT", [ OptV None ]) -> Ast.Select None
  | CaseV ("SELECT", [ OptV (Some (ListV vs)) ]) ->
    let vs' = Array.to_list !vs in
    Ast.Select (Some (List.map al_to_val_type vs'))
  | CaseV ("LOCAL.GET", [ idx ]) -> Ast.LocalGet (al_to_idx idx)
  | CaseV ("LOCAL.SET", [ idx ]) -> Ast.LocalSet (al_to_idx idx)
  | CaseV ("LOCAL.TEE", [ idx ]) -> Ast.LocalTee (al_to_idx idx)
  | CaseV ("GLOBAL.GET", [ idx ]) -> Ast.GlobalGet (al_to_idx idx)
  | CaseV ("GLOBAL.SET", [ idx ]) -> Ast.GlobalSet (al_to_idx idx)
  | CaseV ("TABLE.GET", [ idx ]) -> Ast.TableGet (al_to_idx idx)
  | CaseV ("TABLE.SET", [ idx ]) -> Ast.TableSet (al_to_idx idx)
  | CaseV ("TABLE.SIZE", [ idx ]) -> Ast.TableSize (al_to_idx idx)
  | CaseV ("TABLE.GROW", [ idx ]) -> Ast.TableGrow (al_to_idx idx)
  | CaseV ("TABLE.FILL", [ idx ]) -> Ast.TableFill (al_to_idx idx)
  | CaseV ("TABLE.COPY", [ idx1; idx2 ]) -> Ast.TableCopy (al_to_idx idx1, al_to_idx idx2)
  | CaseV ("TABLE.INIT", [ idx1; idx2 ]) -> Ast.TableInit (al_to_idx idx1, al_to_idx idx2)
  | CaseV ("ELEM.DROP", [ idx ]) -> Ast.ElemDrop (al_to_idx idx)
  | CaseV ("BLOCK", [ bt; ListV instrs ]) ->
    let instrs' = Array.to_list !instrs in
    Ast.Block (al_to_block_type bt, List.map al_to_instr instrs')
  | CaseV ("LOOP", [ bt; ListV instrs ]) ->
    let instrs' = Array.to_list !instrs in
    Ast.Loop (al_to_block_type bt, List.map al_to_instr instrs')
  | CaseV ("IF", [ bt; ListV instrs1; ListV instrs2 ]) ->
    let instrs1' = Array.to_list !instrs1 in
    let instrs2' = Array.to_list !instrs2 in
    Ast.If (al_to_block_type bt, List.map al_to_instr instrs1', List.map al_to_instr instrs2')
  | CaseV ("BR", [ idx ]) -> Ast.Br (al_to_idx idx)
  | CaseV ("BR_IF", [ idx ]) -> Ast.BrIf (al_to_idx idx)
  | CaseV ("BR_TABLE", [ ListV idxs; idx ]) ->
    let idxs' = Array.to_list !idxs in
    Ast.BrTable (List.map al_to_idx idxs', al_to_idx idx)
  | CaseV ("BR_ON_NULL", [ idx ]) -> Ast.BrOnNull (al_to_idx idx)
  | CaseV ("BR_ON_NON_NULL", [ idx ]) -> Ast.BrOnNonNull (al_to_idx idx)
  | CaseV ("BR_ON_CAST", [ idx; rt1; rt2 ]) ->
    Ast.BrOnCast (al_to_idx idx, al_to_ref_type rt1, al_to_ref_type rt2)
  | CaseV ("BR_ON_CAST_FAIL", [ idx; rt1; rt2 ]) ->
    Ast.BrOnCastFail (al_to_idx idx, al_to_ref_type rt1, al_to_ref_type rt2)
  | CaseV ("RETURN", []) -> Ast.Return
  | CaseV ("CALL", [ idx ]) -> Ast.Call (al_to_idx idx)
  | CaseV ("CALL_REF", [ OptV (Some idx) ]) -> Ast.CallRef (al_to_idx idx)
  | CaseV ("CALL_INDIRECT", [ idx1; idx2 ]) ->
    Ast.CallIndirect (al_to_idx idx1, al_to_idx idx2)
  | CaseV ("RETURN_CALL", [ idx ]) -> Ast.ReturnCall (al_to_idx idx)
  | CaseV ("RETURN_CALL_REF", [ OptV (Some idx) ]) -> Ast.ReturnCallRef (al_to_idx idx)
  | CaseV ("RETURN_CALL_INDIRECT", [ idx1; idx2 ]) ->
    Ast.ReturnCallIndirect (al_to_idx idx1, al_to_idx idx2)
  | v -> fail "instrunction" v
