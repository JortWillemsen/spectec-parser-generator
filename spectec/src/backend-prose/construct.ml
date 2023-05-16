open Reference_interpreter
open Source
open Al

let al_of_wasm_num n =
  let s = Values.string_of_num n in
  let t = Values.type_of_num n in
  match t with
  | I32Type | I64Type ->
      WasmInstrV ("const", [ WasmTypeV (NumType t); IntV (int_of_string s) ])
  | F32Type | F64Type ->
      WasmInstrV ("const", [ WasmTypeV (NumType t); FloatV (float_of_string s) ])

let al_of_wasm_instr winstr =
  let f_i32 f i32 = WasmInstrV (f, [ IntV (Int32.to_int i32.it) ]) in

  match winstr.it with
  (* wasm values *)
  | Ast.Const num -> al_of_wasm_num num.it
  | Ast.RefNull t -> WasmInstrV ("ref.null", [ WasmTypeV (RefType t) ])
  (* wasm instructions *)
  | Ast.Nop -> WasmInstrV ("nop", [])
  | Ast.Drop -> WasmInstrV ("drop", [])
  | Ast.Binary (Values.I32 Ast.I32Op.Add) ->
      WasmInstrV
        ("binop", [ WasmTypeV (Types.NumType Types.I32Type); StringV "Add" ])
  | Ast.Test (Values.I32 Ast.I32Op.Eqz) ->
      WasmInstrV
        ("testop", [ WasmTypeV (Types.NumType Types.I32Type); StringV "Eqz" ])
  | Ast.Compare (Values.F32 Ast.F32Op.Gt) ->
      WasmInstrV
        ("relop", [ WasmTypeV (Types.NumType Types.F32Type); StringV "Gt" ])
  | Ast.Compare (Values.I32 Ast.I32Op.GtS) ->
      WasmInstrV
        ("relop", [ WasmTypeV (Types.NumType Types.I32Type); StringV "GtS" ])
  | Ast.Select None -> WasmInstrV ("select", [ StringV "TODO: None" ])
  | Ast.LocalGet i32 -> f_i32 "local.get" i32
  | Ast.LocalSet i32 -> f_i32 "local.set" i32
  | Ast.LocalTee i32 -> f_i32 "local.tee" i32
  | Ast.GlobalGet i32 -> f_i32 "global.get" i32
  | Ast.GlobalSet i32 -> f_i32 "global.set" i32
  | Ast.TableGet i32 -> f_i32 "table.get" i32
  | Ast.Call i32 -> f_i32 "call" i32
  | _ -> failwith "Not implemented"

let al_of_wasm_instrs winstrs = List.map al_of_wasm_instr winstrs

(* Test Interpreter *)

let al_of_wasm_func wasm_module wasm_func =

  (* Get function type from module *)
  (* Note: function type will be placed in function in DSL *)
  let { it = Types.FuncType (wtl1, wtl2); _ } =
    Int32.to_int wasm_func.it.Ast.ftype.it
    |> List.nth wasm_module.it.Ast.types in

  (* Construct function type *)
  let ftype =
    let al_og_wasm_type ty = WasmTypeV ty in
    let al_tl1 = List.map al_og_wasm_type wtl1 in
    let al_tl2 = List.map al_og_wasm_type wtl2 in
    ArrowV (ListV (Array.of_list al_tl1), ListV (Array.of_list al_tl2)) in

  (* Construct code *)
  let code = al_of_wasm_instrs wasm_func.it.Ast.body |> Array.of_list in

  ConstructV ("FUNC", [ftype; ListV [||]; ListV (code)])

let al_of_wasm_module wasm_module =

  (* Construct functions *)
  let func_list =
    List.map (al_of_wasm_func wasm_module) wasm_module.it.funcs
    |> Array.of_list
    in

  ConstructV ("MODULE", [ListV func_list])
