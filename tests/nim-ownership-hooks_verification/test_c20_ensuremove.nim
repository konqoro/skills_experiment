# C20: ensureMove works for any value last-use analysis can prove is movable:
# rvalues, local variables (last use), and sink parameters.
# Fails when the value would need an implicit copy.
type
  Val = object
    data: ptr int

proc `=destroy`*(x: var Val) =
  if x.data != nil:
    dealloc(x.data)

proc `=wasMoved`*(x: var Val) = x.data = nil
proc `=copy`*(dest: var Val; src: Val) {.error.}
proc `=dup`*(src: Val): Val {.error.}

proc newVal(v: int): Val =
  result.data = create(int)
  result.data[] = v

proc consume(x: sink Val) =
  doAssert x.data != nil

proc main() =
  # ensureMove on rvalue
  consume(ensureMove(newVal(1)))

  # ensureMove on last-use local variable
  var a = newVal(42)
  var b = ensureMove(a)
  doAssert b.data[] == 42

  # ensureMove on sink param (already sink, ensureMove is redundant but works)
  var c = newVal(99)
  consume(ensureMove(c))

  echo "C20: PASS"

main()
