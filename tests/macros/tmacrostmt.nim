import macros
macro case_token(n: varargs[untyped]): untyped =
  # creates a lexical analyzer from regular expressions
  # ... (implementation is an exercise for the reader :-)
  nil

case_token: # this colon tells the parser it is a macro statement
of r"[A-Za-z_]+[A-Za-z_0-9]*":
  return tkIdentifier
of r"0-9+":
  return tkInteger
of r"[\+\-\*\?]+":
  return tkOperator
else:
  return tkUnknown

case_token: inc i

#bug #488

macro foo: typed =
  var exp = newCall("whatwhat", newIntLitNode(1))
  if compiles(getAst(exp)): return exp
  else: echo "Does not compute! (test OK)"

foo()

#------------------------------------
# bug #8287 
type MyString = distinct string

proc `$` (c: MyString): string {.borrow.}

proc `!!` (c: cstring): int =
  c.len

proc f(name: MyString): int =
  !! $ name

macro repr_and_parse(fn: typed): typed =
  let fn_impl = fn.getImpl
  fn_impl.name = genSym(nskProc, $fn_impl.name)
  echo fn_impl.repr
  result = parseStmt(fn_impl.repr)

macro repr_to_string(fn: typed): string =
  let fn_impl = fn.getImpl
  result = newStrLitNode(fn_impl.repr)

repr_and_parse(f)


#------------------------------------
# bugs #8343 and #8344 
proc one_if_proc(x, y : int): int =
  if x < y: result = x
  else: result = y

proc test_block(x, y : int): int =
  block label:
    result = x
    result = y

#------------------------------------
# bugs #8348

template `>`(x, y: untyped): untyped =
  ## "is greater" operator. This is the same as ``y < x``.
  y < x

proc test_cond_stmtlist(x, y: int): int =
  result = x
  if x > y:
    result = x


#------------------------------------
# bug #8762
proc t2(a, b: int): int =  
  `+`(a, b)


#------------------------------------
# bug #8761

proc fn1(x, y: int):int =
  2 * (x + y)

proc fn2(x, y: float): float =
  (y + 2 * x) / (x - y)

proc fn3(x, y: int): bool =
  (((x and 3) div 4) or (x mod (y xor -1))) == 0 or y notin [1,2]
  
static:
  let fn1s = "proc fn1(x, y: int): int =\n  result = 2 * (x + y)\n"
  let fn2s = "proc fn2(x, y: float): float =\n  result = (y + 2 * x) / (x - y)\n"
  let fn3s = "proc fn3(x, y: int): bool =\n  result = ((x and 3) div 4 or x mod (y xor -1)) == 0 or not contains([1, 2], y)\n"
  doAssert fn1.repr_to_string == fn1s
  doAssert fn2.repr_to_string == fn2s
  doAssert fn3.repr_to_string == fn3s

#------------------------------------
# bug #8763

type
  A {.pure.} = enum
    X, Y
  B {.pure.} = enum
    X, Y

proc test_pure_enums(a: B) =
  case a
    of B.X: echo B.X
    of B.Y: echo B.Y

repr_and_parse(one_if_proc)
repr_and_parse(test_block)
repr_and_parse(test_cond_stmtlist)
repr_and_parse(t2)
repr_and_parse(test_pure_enums)

