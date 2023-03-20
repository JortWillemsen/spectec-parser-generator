# Preview

```sh
$ dune exec ../src/exe-watsup/main.exe -- syntax.spasm aux.spasm typing.spasm runtime.spasm reduction.spasm
== Parsing...
== Multiplicity checking...
== Lowering...
== Printing...

;; syntax.spasm:8.1-8.37
syntax name = text

;; syntax.spasm:13.1-13.36
syntax byte = nat

;; syntax.spasm:14.1-14.45
syntax u32 = nat

;; syntax.spasm:19.1-19.36
syntax idx = nat

;; syntax.spasm:20.1-20.49
syntax funcidx = idx

;; syntax.spasm:21.1-21.49
syntax globalidx = idx

;; syntax.spasm:22.1-22.47
syntax tableidx = idx

;; syntax.spasm:23.1-23.46
syntax memidx = idx

;; syntax.spasm:24.1-24.45
syntax elemidx = idx

;; syntax.spasm:25.1-25.45
syntax dataidx = idx

;; syntax.spasm:26.1-26.47
syntax labelidx = idx

;; syntax.spasm:27.1-27.47
syntax localidx = idx

;; syntax.spasm:36.1-37.26
syntax numtype =
  | I32
  | I64
  | F32
  | F64

;; syntax.spasm:38.1-39.9
syntax vectype =
  | V128

;; syntax.spasm:40.1-41.24
syntax reftype =
  | FUNCREF
  | EXTERNREF

;; syntax.spasm:42.1-43.38
syntax valtype =
  | numtype
  | vectype
  | reftype
  | BOT

;; syntax.spasm:50.1-51.11
syntax resulttype = valtype*

;; syntax.spasm:53.1-54.16
syntax limits = `[%..%]`(u32, u32)

;; syntax.spasm:55.1-56.15
syntax globaltype = `MUT%?%`(()?, valtype)

;; syntax.spasm:57.1-58.27
syntax functype = `%->%`(resulttype, resulttype)

;; syntax.spasm:59.1-60.17
syntax tabletype = `%%`(limits, reftype)

;; syntax.spasm:61.1-62.12
syntax memtype = `%I8`(limits)

;; syntax.spasm:63.1-64.10
syntax elemtype = reftype

;; syntax.spasm:65.1-66.5
syntax datatype = OK

;; syntax.spasm:67.1-68.70
syntax externtype =
  | GLOBAL(globaltype)
  | FUNC(functype)
  | TABLE(tabletype)
  | MEM(memtype)

;; syntax.spasm:81.1-81.23
syntax c_numtype = nat

;; syntax.spasm:82.1-82.23
syntax c_vectype = nat

;; syntax.spasm:85.1-85.44
syntax sx =
  | U
  | S

;; syntax.spasm:87.1-87.52
syntax blocktype = functype

;; syntax.spasm:90.1-90.26
syntax unop_numtype = XXX

;; syntax.spasm:91.1-91.27
syntax binop_numtype = XXX

;; syntax.spasm:92.1-92.28
syntax testop_numtype = XXX

;; syntax.spasm:93.1-93.27
syntax relop_numtype = XXX

;; syntax.spasm:94.1-94.19
syntax cvtop = XXX

;; syntax.spasm:101.1-145.60
rec {

;; syntax.spasm:101.1-145.60
syntax instr =
  | UNREACHABLE
  | NOP
  | DROP
  | SELECT(valtype?)
  | BLOCK(blocktype, instr*)
  | LOOP(blocktype, instr*)
  | IF(blocktype, instr*, instr*)
  | BR(labelidx)
  | BR_IF(labelidx)
  | BR_TABLE(labelidx*, labelidx)
  | CALL(funcidx)
  | CALL_INDIRECT(tableidx, functype)
  | RETURN
  | CONST(numtype, c_numtype)
  | UNOP(numtype, unop_numtype)
  | BINOP(numtype, binop_numtype)
  | TESTOP(numtype, testop_numtype)
  | RELOP(numtype, relop_numtype)
  | EXTEND(numtype, nat)
  | CVTOP(numtype, cvtop, numtype, sx?)
  | REF.NULL(reftype)
  | REF.FUNC(funcidx)
  | REF.IS_NULL
  | LOCAL.GET(localidx)
  | LOCAL.SET(localidx)
  | LOCAL.TEE(localidx)
  | GLOBAL.GET(globalidx)
  | GLOBAL.SET(globalidx)
  | TABLE.GET(tableidx)
  | TABLE.SET(tableidx)
  | TABLE.SIZE(tableidx)
  | TABLE.GROW(tableidx)
  | TABLE.FILL(tableidx)
  | TABLE.COPY(tableidx, tableidx)
  | TABLE.INIT(tableidx, elemidx)
  | ELEM.DROP(elemidx)
  | MEMORY.SIZE
  | MEMORY.GROW
  | MEMORY.FILL
  | MEMORY.COPY
  | MEMORY.INIT(dataidx)
  | DATA.DROP(dataidx)
  | LOAD(numtype, (nat, sx)?, nat, nat)
  | STORE(numtype, nat?, nat, nat)
}

;; syntax.spasm:147.1-148.9
syntax expr = instr*

;; syntax.spasm:153.1-155.12
syntax elemmode =
  | TABLE(tableidx, expr)
  | DECLARE

;; syntax.spasm:156.1-157.23
syntax datamode =
  | MEMORY(memidx, expr)

;; syntax.spasm:159.1-160.30
syntax func = FUNC(functype, valtype*, expr)

;; syntax.spasm:161.1-162.25
syntax global = GLOBAL(globaltype, expr)

;; syntax.spasm:163.1-164.18
syntax table = TABLE(tabletype)

;; syntax.spasm:165.1-166.14
syntax mem = MEM(memtype)

;; syntax.spasm:167.1-168.31
syntax elem = ELEM(reftype, expr*, elemmode?)

;; syntax.spasm:169.1-170.26
syntax data = DATA(byte**, datamode?)

;; syntax.spasm:171.1-172.16
syntax start = START(funcidx)

;; syntax.spasm:174.1-175.66
syntax externuse =
  | FUNC(funcidx)
  | GLOBAL(globalidx)
  | TABLE(tableidx)
  | MEM(memidx)

;; syntax.spasm:176.1-177.24
syntax export = EXPORT(name, externuse)

;; syntax.spasm:178.1-179.30
syntax import = IMPORT(name, name, externtype)

;; syntax.spasm:181.1-182.70
syntax module = MODULE(import*, func*, global*, table*, mem*, elem*, data*, start*, export*)

;; aux.spasm:5.1-5.41
def size : numtype -> nat
  ;; aux.spasm:9.1-9.20
  def size(F64) = 64
  ;; aux.spasm:8.1-8.20
  def size(F32) = 32
  ;; aux.spasm:7.1-7.20
  def size(I64) = 64
  ;; aux.spasm:6.1-6.20
  def size(I32) = 32

;; typing.spasm:3.1-13.4
syntax context = {FUNC functype*, GLOBAL globaltype*, TABLE tabletype*, MEM memtype*, ELEM elemtype*, DATA datatype*, LOCAL valtype*, LABEL resulttype*, RETURN resulttype?}

;; typing.spasm:21.1-21.39
relation Functype_ok: `|-%:OK`(functype)
  ;; typing.spasm:27.1-28.13
  rule _ {ft : functype}:
    `|-%:OK`(ft)

;; typing.spasm:22.1-22.43
relation Globaltype_ok: `|-%:OK`(globaltype)
  ;; typing.spasm:30.1-31.13
  rule _ {gt : globaltype}:
    `|-%:OK`(gt)

;; typing.spasm:25.1-25.36
relation Limits_ok: `|-%:%`(limits, nat)
  ;; typing.spasm:41.1-43.25
  rule _ {k : nat, n_1 : nat, n_2 : nat}:
    `|-%:%`(`[%..%]`(n_1, n_2), k)
    -- iff ((n_1 <= n_2) /\ (n_2 <= k))

;; typing.spasm:23.1-23.41
relation Tabletype_ok: `|-%:OK`(tabletype)
  ;; typing.spasm:33.1-35.35
  rule _ {lim : limits, rt : reftype}:
    `|-%:OK`(`%%`(lim, rt))
    -- Limits_ok: `|-%:%`(lim, ((2 ^ 32) - 1))

;; typing.spasm:24.1-24.37
relation Memtype_ok: `|-%:OK`(memtype)
  ;; typing.spasm:37.1-39.33
  rule _ {lim : limits}:
    `|-%:OK`(`%I8`(lim))
    -- Limits_ok: `|-%:%`(lim, (2 ^ 16))

;; typing.spasm:49.1-49.44
relation Valtype_sub: `|-%<:%`(valtype, valtype)
  ;; typing.spasm:55.1-56.14
  rule bot {t : valtype}:
    `|-%<:%`(BOT, t)

  ;; typing.spasm:52.1-53.12
  rule refl {t : valtype}:
    `|-%<:%`(t, t)

;; typing.spasm:50.1-50.49
relation Resulttype_sub: `|-%<:%`(valtype*, valtype*)
  ;; typing.spasm:58.1-60.35
  rule _ {t_1 : valtype, t_2 : valtype}:
    `|-%<:%`(t_1*, t_2*)
    -- (Valtype_sub: `|-%<:%`(t_1, t_2))*

;; typing.spasm:63.1-63.47
relation Functype_sub: `|-%<:%`(functype, functype)
  ;; typing.spasm:70.1-71.14
  rule _ {ft : functype}:
    `|-%<:%`(ft, ft)

;; typing.spasm:64.1-64.53
relation Globaltype_sub: `|-%<:%`(globaltype, globaltype)
  ;; typing.spasm:73.1-74.14
  rule _ {gt : globaltype}:
    `|-%<:%`(gt, gt)

;; typing.spasm:67.1-67.41
relation Limits_sub: `|-%<:%`(limits, limits)
  ;; typing.spasm:84.1-87.22
  rule _ {n_11 : nat, n_12 : nat, n_21 : nat, n_22 : nat}:
    `|-%<:%`(`[%..%]`(n_11, n_12), `[%..%]`(n_21, n_22))
    -- iff (n_11 >= n_21)
    -- iff (n_12 <= n_22)

;; typing.spasm:65.1-65.50
relation Tabletype_sub: `|-%<:%`(tabletype, tabletype)
  ;; typing.spasm:76.1-78.35
  rule _ {lim_1 : limits, lim_2 : limits, rt : reftype}:
    `|-%<:%`(`%%`(lim_1, rt), `%%`(lim_2, rt))
    -- Limits_sub: `|-%<:%`(lim_1, lim_2)

;; typing.spasm:66.1-66.44
relation Memtype_sub: `|-%<:%`(memtype, memtype)
  ;; typing.spasm:80.1-82.35
  rule _ {lim_1 : limits, lim_2 : limits}:
    `|-%<:%`(`%I8`(lim_1), `%I8`(lim_2))
    -- Limits_sub: `|-%<:%`(lim_1, lim_2)

;; typing.spasm:68.1-68.53
relation Externtype_sub: `|-%<:%`(externtype, externtype)
  ;; typing.spasm:101.1-103.34
  rule mem {mt_1 : memtype, mt_2 : memtype}:
    `|-%<:%`(MEM(mt_1), MEM(mt_2))
    -- Memtype_sub: `|-%<:%`(mt_1, mt_2)

  ;; typing.spasm:97.1-99.36
  rule table {tt_1 : tabletype, tt_2 : tabletype}:
    `|-%<:%`(TABLE(tt_1), TABLE(tt_2))
    -- Tabletype_sub: `|-%<:%`(tt_1, tt_2)

  ;; typing.spasm:93.1-95.37
  rule global {gt_1 : globaltype, gt_2 : globaltype}:
    `|-%<:%`(GLOBAL(gt_1), GLOBAL(gt_2))
    -- Globaltype_sub: `|-%<:%`(gt_1, gt_2)

  ;; typing.spasm:89.1-91.35
  rule func {ft_1 : functype, ft_2 : functype}:
    `|-%<:%`(FUNC(ft_1), FUNC(ft_2))
    -- Functype_sub: `|-%<:%`(ft_1, ft_2)

;; typing.spasm:150.1-150.55
relation Blocktype_ok: `%|-%:%`(context, blocktype, functype)
  ;; typing.spasm:151.1-153.29
  rule _ {C : context, ft : functype}:
    `%|-%:%`(C, ft, ft)
    -- Functype_ok: `|-%:OK`(ft)

;; typing.spasm:109.1-110.51
rec {

;; typing.spasm:109.1-109.47
relation Instr_ok: `%|-%:%`(context, instr, functype)
  ;; typing.spasm:211.1-212.37
  rule relop {C : context, nt : numtype, relop : relop_numtype}:
    `%|-%:%`(C, RELOP(nt, relop), `%->%`([(nt <: valtype)] :: [(nt <: valtype)], [I32]))

  ;; typing.spasm:208.1-209.36
  rule testop {C : context, nt : numtype, testop : testop_numtype}:
    `%|-%:%`(C, TESTOP(nt, testop), `%->%`([(nt <: valtype)], [I32]))

  ;; typing.spasm:205.1-206.36
  rule binop {C : context, binop : binop_numtype, nt : numtype}:
    `%|-%:%`(C, BINOP(nt, binop), `%->%`([(nt <: valtype)] :: [(nt <: valtype)], [(nt <: valtype)]))

  ;; typing.spasm:202.1-203.31
  rule unop {C : context, nt : numtype, unop : unop_numtype}:
    `%|-%:%`(C, UNOP(nt, unop), `%->%`([(nt <: valtype)], [(nt <: valtype)]))

  ;; typing.spasm:199.1-200.37
  rule const {C : context, c_nt : c_numtype, nt : numtype}:
    `%|-%:%`(C, CONST(nt, c_nt), `%->%`([], [(nt <: valtype)]))

  ;; typing.spasm:193.1-196.27
  rule call_indirect {C : context, ft : functype, lim : limits, t_1 : valtype, t_2 : valtype, x : idx}:
    `%|-%:%`(C, CALL_INDIRECT(x, ft), `%->%`(t_1* :: [I32], t_2*))
    -- iff (C.TABLE[x] = `%%`(lim, FUNCREF))
    -- iff (ft = `%->%`(t_1*, t_2*))

  ;; typing.spasm:189.1-191.34
  rule call {C : context, t_1 : valtype, t_2 : valtype, x : idx}:
    `%|-%:%`(C, CALL(x), `%->%`(t_1*, t_2*))
    -- iff (C.FUNC[x] = `%->%`(t_1*, t_2*))

  ;; typing.spasm:185.1-187.25
  rule return {C : context, t : valtype, t_1 : valtype, t_2 : valtype}:
    `%|-%:%`(C, RETURN, `%->%`(t_1* :: t*, t_2*))
    -- iff (C.RETURN = ?(t*))

  ;; typing.spasm:180.1-183.42
  rule br_table {C : context, l : labelidx, l' : labelidx, t : valtype, t_1 : valtype, t_2 : valtype}:
    `%|-%:%`(C, BR_TABLE(l*, l'), `%->%`(t_1* :: t*, t_2*))
    -- (Resulttype_sub: `|-%<:%`(t*, C.LABEL[l]))*
    -- Resulttype_sub: `|-%<:%`(t*, C.LABEL[l'])

  ;; typing.spasm:176.1-178.25
  rule br_if {C : context, l : labelidx, t : valtype}:
    `%|-%:%`(C, BR_IF(l), `%->%`(t* :: [I32], t*))
    -- iff (C.LABEL[l] = t*)

  ;; typing.spasm:172.1-174.25
  rule br {C : context, l : labelidx, t : valtype, t_1 : valtype, t_2 : valtype}:
    `%|-%:%`(C, BR(l), `%->%`(t_1* :: t*, t_2*))
    -- iff (C.LABEL[l] = t*)

  ;; typing.spasm:165.1-169.59
  rule if {C : context, bt : blocktype, instr_1 : instr, instr_2 : instr, t_1 : valtype, t_2 : valtype}:
    `%|-%:%`(C, IF(bt, instr_1*, instr_2*), `%->%`(t_1*, [t_2]))
    -- Blocktype_ok: `%|-%:%`(C, bt, `%->%`(t_1*, [t_2]))
    -- InstrSeq_ok: `%|-%:%`(C ++ {FUNC [], GLOBAL [], TABLE [], MEM [], ELEM [], DATA [], LOCAL [], LABEL [t_2]*, RETURN ?()}, instr_1*, `%->%`(t_1*, t_2*))
    -- InstrSeq_ok: `%|-%:%`(C ++ {FUNC [], GLOBAL [], TABLE [], MEM [], ELEM [], DATA [], LOCAL [], LABEL [t_2]*, RETURN ?()}, instr_2*, `%->%`(t_1*, t_2*))

  ;; typing.spasm:160.1-163.56
  rule loop {C : context, bt : blocktype, instr : instr, t_1 : valtype, t_2 : valtype}:
    `%|-%:%`(C, LOOP(bt, instr*), `%->%`(t_1*, t_2*))
    -- Blocktype_ok: `%|-%:%`(C, bt, `%->%`(t_1*, t_2*))
    -- InstrSeq_ok: `%|-%:%`(C ++ {FUNC [], GLOBAL [], TABLE [], MEM [], ELEM [], DATA [], LOCAL [], LABEL [t_1]*, RETURN ?()}, instr*, `%->%`(t_1*, [t_2]))

  ;; typing.spasm:155.1-158.57
  rule block {C : context, bt : blocktype, instr : instr, t_1 : valtype, t_2 : valtype}:
    `%|-%:%`(C, BLOCK(bt, instr*), `%->%`(t_1*, t_2*))
    -- Blocktype_ok: `%|-%:%`(C, bt, `%->%`(t_1*, t_2*))
    -- InstrSeq_ok: `%|-%:%`(C ++ {FUNC [], GLOBAL [], TABLE [], MEM [], ELEM [], DATA [], LOCAL [], LABEL [t_2]*, RETURN ?()}, instr*, `%->%`(t_1*, t_2*))

  ;; typing.spasm:144.1-147.38
  rule select-impl {C : context, numtype : numtype, t : valtype, t' : valtype, vectype : vectype}:
    `%|-%:%`(C, SELECT(?()), `%->%`([t] :: [t] :: [I32], [t]))
    -- Valtype_sub: `|-%<:%`(t, t')
    -- iff ((t' = (numtype <: valtype)) \/ (t' = (vectype <: valtype)))

  ;; typing.spasm:141.1-142.31
  rule select-expl {C : context, t : valtype}:
    `%|-%:%`(C, SELECT(?(t)), `%->%`([t] :: [t] :: [I32], [t]))

  ;; typing.spasm:137.1-138.27
  rule drop {C : context, t : valtype}:
    `%|-%:%`(C, DROP, `%->%`([t], []))

  ;; typing.spasm:134.1-135.32
  rule nop {C : context}:
    `%|-%:%`(C, NOP, `%->%`([], []))

  ;; typing.spasm:131.1-132.34
  rule unreachable {C : context, t_1 : valtype, t_2 : valtype}:
    `%|-%:%`(C, UNREACHABLE, `%->%`(t_1*, t_2*))

;; typing.spasm:110.1-110.51
relation InstrSeq_ok: `%|-%:%`(context, instr*, functype)
  ;; typing.spasm:126.1-128.45
  rule frame {C : context, instr : instr, t : valtype, t_1 : valtype, t_2 : valtype}:
    `%|-%:%`(C, instr*, `%->%`(t* :: t_1*, t* :: t_2*))
    -- InstrSeq_ok: `%|-%:%`(C, instr*, `%->%`(t_1*, t_2*))

  ;; typing.spasm:120.1-124.38
  rule weak {C : context, instr : instr, t'_1 : valtype, t'_2 : valtype, t_1 : valtype, t_2 : valtype}:
    `%|-%:%`(C, instr*, `%->%`([t'_1], t'_2*))
    -- InstrSeq_ok: `%|-%:%`(C, instr*, `%->%`(t_1*, t_2*))
    -- Resulttype_sub: `|-%<:%`(t'_1*, t_1*)
    -- Resulttype_sub: `|-%<:%`(t_2*, t'_2*)

  ;; typing.spasm:115.1-118.46
  rule seq {C : context, instr_1 : instr, instr_2 : instr, t_1 : valtype, t_2 : valtype, t_3 : valtype}:
    `%|-%:%`(C, [instr_1] :: instr_2*, `%->%`(t_1*, t_3*))
    -- Instr_ok: `%|-%:%`(C, instr_1, `%->%`(t_1*, t_2*))
    -- InstrSeq_ok: `%|-%:%`(C, [instr_2], `%->%`(t_2*, t_3*))

  ;; typing.spasm:112.1-113.36
  rule empty {C : context}:
    `%|-%:%`(C, [], `%->%`([], []))
}

;; typing.spasm:220.1-220.45
relation Instr_const: `%|-%CONST`(context, instr)
  ;; typing.spasm:232.1-234.33
  rule global.get {C : context, t : valtype, x : idx}:
    `%|-%CONST`(C, GLOBAL.GET(x))
    -- iff (C.GLOBAL[x] = `MUT%?%`(?(), t))

  ;; typing.spasm:229.1-230.26
  rule ref.func {C : context, x : idx}:
    `%|-%CONST`(C, REF.FUNC(x))

  ;; typing.spasm:226.1-227.27
  rule ref.null {C : context, rt : reftype}:
    `%|-%CONST`(C, REF.NULL(rt))

  ;; typing.spasm:223.1-224.26
  rule const {C : context, c : c_numtype, nt : numtype}:
    `%|-%CONST`(C, CONST(nt, c))

;; typing.spasm:221.1-221.49
relation InstrSeq_const: `%|-%CONST`(context, instr*)
  ;; typing.spasm:237.1-238.38
  rule _ {C : context, instr : instr}:
    `%|-%CONST`(C, instr*)
    -- (Instr_const: `%|-%CONST`(C, instr))*

;; runtime.spasm:3.1-3.39
syntax addr = nat

;; runtime.spasm:4.1-4.53
syntax funcaddr = addr

;; runtime.spasm:5.1-5.53
syntax globaladdr = addr

;; runtime.spasm:6.1-6.51
syntax tableaddr = addr

;; runtime.spasm:7.1-7.50
syntax memaddr = addr

;; runtime.spasm:8.1-8.49
syntax elemaddr = addr

;; runtime.spasm:9.1-9.49
syntax dataaddr = addr

;; runtime.spasm:10.1-10.51
syntax labeladdr = addr

;; runtime.spasm:11.1-11.49
syntax hostaddr = addr

;; runtime.spasm:24.1-25.28
syntax num =
  | CONST(numtype, c_numtype)

;; runtime.spasm:26.1-27.71
syntax ref =
  | REF.NULL(reftype)
  | REF.FUNC_ADDR(funcaddr)
  | REF.HOST_ADDR(hostaddr)

;; runtime.spasm:28.1-29.14
syntax val =
  | num
  | ref

;; runtime.spasm:31.1-32.22
syntax result =
  | _VALS(val*)
  | TRAP

;; runtime.spasm:38.1-39.70
syntax externval =
  | FUNC(funcaddr)
  | GLOBAL(globaladdr)
  | TABLE(tableaddr)
  | MEM(memaddr)

;; runtime.spasm:44.1-44.28
def default : valtype -> val
  ;; runtime.spasm:49.1-49.43
  def {reftype : reftype} default(reftype <: valtype) = REF.NULL(reftype)
  ;; runtime.spasm:48.1-48.34
  def default(F64) = CONST(F64, 0)
  ;; runtime.spasm:47.1-47.34
  def default(F32) = CONST(F32, 0)
  ;; runtime.spasm:46.1-46.34
  def default(I64) = CONST(I64, 0)
  ;; runtime.spasm:45.1-45.34
  def default(I32) = CONST(I32, 0)

;; runtime.spasm:60.1-60.71
syntax exportinst = EXPORT(name, externval)

;; runtime.spasm:71.1-79.4
syntax moduleinst = {FUNC funcaddr*, GLOBAL globaladdr*, TABLE tableaddr*, MEM memaddr*, ELEM elemaddr*, DATA dataaddr*, EXPORT exportinst*}

;; runtime.spasm:54.1-54.66
syntax funcinst = `%;%`(moduleinst, func)

;; runtime.spasm:55.1-55.53
syntax globalinst = val

;; runtime.spasm:56.1-56.52
syntax tableinst = ref*

;; runtime.spasm:57.1-57.52
syntax meminst = byte*

;; runtime.spasm:58.1-58.53
syntax eleminst = ref*

;; runtime.spasm:59.1-59.51
syntax datainst = byte*

;; runtime.spasm:62.1-69.4
syntax store = {FUNC funcinst*, GLOBAL globalinst*, TABLE tableinst*, MEM meminst*, ELEM eleminst*, DATA datainst*}

;; runtime.spasm:81.1-81.51
syntax frame = `%;%`(moduleinst, val*)

;; runtime.spasm:82.1-82.47
syntax state = `%;%`(store, frame)

;; runtime.spasm:113.1-120.9
rec {

;; runtime.spasm:113.1-120.9
syntax admininstr =
  | instr
  | REF.FUNC_ADDR(funcaddr)
  | REF.HOST_ADDR(hostaddr)
  | CALL_ADDR(funcaddr)
  | LABEL(nat, instr*, admininstr*)
  | FRAME(nat, frame, admininstr*)
  | TRAP
}

;; runtime.spasm:83.1-83.62
syntax config = `%;%`(state, admininstr*)

;; runtime.spasm:98.1-98.52
def funcaddr : state -> funcaddr*
  ;; runtime.spasm:99.1-99.37
  def {m : moduleinst, s : store, val : val} funcaddr(`%;%`(s, `%;%`(m, val*))) = m.FUNC

;; runtime.spasm:101.1-101.52
def funcinst : state -> funcinst*
  ;; runtime.spasm:102.1-102.29
  def {f : frame, s : store} funcinst(`%;%`(s, f)) = s.FUNC

;; runtime.spasm:104.1-104.56
def func : (state, funcidx) -> funcinst
  ;; runtime.spasm:105.1-105.49
  def {m : moduleinst, s : store, val : val, x : idx} func(`%;%`(s, `%;%`(m, val*)), x) = s.FUNC[m.FUNC[x]]

;; runtime.spasm:107.1-107.60
def table : (state, tableidx) -> tableinst
  ;; runtime.spasm:108.1-108.52
  def {m : moduleinst, s : store, val : val, x : idx} table(`%;%`(s, `%;%`(m, val*)), x) = s.TABLE[m.TABLE[x]]

;; runtime.spasm:122.1-125.23
syntax `E =
  | _HOLE
  | _SEQ(val*, instr*)
  | LABEL(nat, instr*)

;; reduction.spasm:5.1-5.47
relation Step_pure: `%~>%`(admininstr*, admininstr*)
  ;; reduction.spasm:70.1-72.19
  rule br_table-le {i : nat, l : labelidx, l' : labelidx}:
    `%~>%`([CONST(I32, i) BR_TABLE(l*, l')], [BR(l')])
    -- iff (i >= |l*|)

  ;; reduction.spasm:66.1-68.18
  rule br_table-lt {i : nat, l : labelidx, l' : labelidx}:
    `%~>%`([CONST(I32, i) BR_TABLE(l*, l')], [BR(l*[i])])
    -- iff (i < |l*|)

  ;; reduction.spasm:61.1-63.15
  rule br_if-false {c : c_numtype, l : labelidx}:
    `%~>%`([CONST(I32, c) BR_IF(l)], [])
    -- iff (c = 0)

  ;; reduction.spasm:57.1-59.17
  rule br_if-true {c : c_numtype, l : labelidx}:
    `%~>%`([CONST(I32, c) BR_IF(l)], [BR(l)])
    -- iff (c =/= 0)

  ;; reduction.spasm:53.1-54.63
  rule br-succ {instr : instr, instr' : instr, l : labelidx, n : nat, val : val}:
    `%~>%`([LABEL(n, instr'*, (val <: admininstr)* :: [BR(l + 1)] :: (instr <: admininstr)*)], (val <: admininstr)* :: [BR(l)])

  ;; reduction.spasm:50.1-51.67
  rule br-zero {instr : instr, instr' : instr, n : nat, val : val, val' : val}:
    `%~>%`([LABEL(n, instr'*, (val' <: admininstr)* :: (val <: admininstr)^n :: [BR(0)] :: (instr <: admininstr)*)], (val <: admininstr)^n :: (instr' <: admininstr)*)

  ;; reduction.spasm:45.1-47.15
  rule if-false {bt : blocktype, c : c_numtype, instr_1 : instr, instr_2 : instr}:
    `%~>%`([CONST(I32, c) IF(bt, instr_1*, instr_2*)], [BLOCK(bt, instr_2*)])
    -- iff (c = 0)

  ;; reduction.spasm:41.1-43.17
  rule if-true {bt : blocktype, c : c_numtype, instr_1 : instr, instr_2 : instr}:
    `%~>%`([CONST(I32, c) IF(bt, instr_1*, instr_2*)], [BLOCK(bt, instr_1*)])
    -- iff (c =/= 0)

  ;; reduction.spasm:37.1-39.29
  rule loop {bt : blocktype, instr : instr, k : nat, n : nat, t_1 : valtype, t_2 : valtype, val : val}:
    `%~>%`((val <: admininstr)^k :: [LOOP(bt, instr*)], [LABEL(n, [LOOP(bt, instr*)], (val <: admininstr)^k :: (instr <: admininstr)*)])
    -- iff (bt = `%->%`(t_1^k, t_2^n))

  ;; reduction.spasm:33.1-35.29
  rule block {bt : blocktype, instr : instr, k : nat, n : nat, t_1 : valtype, t_2 : valtype, val : val}:
    `%~>%`((val <: admininstr)^k :: [BLOCK(bt, instr*)], [LABEL(n, [], (val <: admininstr)^k :: (instr <: admininstr)*)])
    -- iff (bt = `%->%`(t_1^k, t_2^n))

  ;; reduction.spasm:29.1-31.15
  rule select-false {c : c_numtype, t : valtype, val_1 : val, val_2 : val}:
    `%~>%`([(val_1 <: admininstr)] :: [(val_2 <: admininstr)] :: [CONST(I32, c) SELECT(t?)], [(val_2 <: admininstr)])
    -- iff (c = 0)

  ;; reduction.spasm:25.1-27.17
  rule select-true {c : c_numtype, t : valtype, val_1 : val, val_2 : val}:
    `%~>%`([(val_1 <: admininstr)] :: [(val_2 <: admininstr)] :: [CONST(I32, c) SELECT(t?)], [(val_1 <: admininstr)])
    -- iff (c =/= 0)

  ;; reduction.spasm:22.1-23.24
  rule drop {val : val}:
    `%~>%`([(val <: admininstr)] :: [DROP], [])

  ;; reduction.spasm:19.1-20.19
  rule nop:
    `%~>%`([NOP], [])

  ;; reduction.spasm:16.1-17.24
  rule unreachable:
    `%~>%`([UNREACHABLE], [TRAP])

;; reduction.spasm:4.1-4.42
relation Step_read: `%~>%`(config, admininstr*)
  ;; reduction.spasm:87.1-89.62
  rule call_addr {a : addr, instr : instr, k : nat, m : moduleinst, n : nat, t : valtype, t_1 : valtype, t_2 : valtype, val : val, z : state}:
    `%~>%`(`%;%`(z, (val <: admininstr)^k :: [CALL_ADDR(a)]), [FRAME(n, `%;%`(m, val^k :: $default(t)*), [LABEL(n, [], (instr <: admininstr)*)])])
    -- iff ($funcinst(z)[a] = `%;%`(m, FUNC(`%->%`(t_1^k, t_2^n), t*, instr*)))

  ;; reduction.spasm:83.1-85.15
  rule call_indirect-trap {ft : functype, i : nat, x : idx, z : state}:
    `%~>%`(`%;%`(z, [CONST(I32, i) CALL_INDIRECT(x, ft)]), [TRAP])
    -- otherwise

  ;; reduction.spasm:78.1-81.35
  rule call_indirect-call {a : addr, ft : functype, func : func, i : nat, m : moduleinst, x : idx, z : state}:
    `%~>%`(`%;%`(z, [CONST(I32, i) CALL_INDIRECT(x, ft)]), [CALL_ADDR(a)])
    -- iff ($table(z, x)[i] = REF.FUNC_ADDR(a))
    -- iff ($funcinst(z)[a] = `%;%`(m, func))

  ;; reduction.spasm:75.1-76.47
  rule call {x : idx, z : state}:
    `%~>%`(`%;%`(z, [CALL(x)]), [CALL_ADDR($funcaddr(z)[x])])

;; reduction.spasm:3.1-3.32
relation Step: `%~>%`(config, config)
  ;; reduction.spasm:11.1-13.37
  rule read {instr : instr, instr' : instr, z : state}:
    `%~>%`(`%;%`(z, (instr <: admininstr)*), `%;%`(z, (instr' <: admininstr)*))
    -- Step_read: `%~>%`(`%;%`(z, (instr <: admininstr)*), (instr' <: admininstr)*)

  ;; reduction.spasm:7.1-9.34
  rule pure {instr : instr, instr' : instr, z : state}:
    `%~>%`(`%;%`(z, (instr <: admininstr)*), `%;%`(z, (instr' <: admininstr)*))
    -- Step_pure: `%~>%`((instr <: admininstr)*, (instr' <: admininstr)*)

== IL Validation...
== Complete.
```