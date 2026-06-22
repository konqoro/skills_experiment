# C53: For move-only types, =dup must also be marked {.error.}.
# Without it, compiler synthesizes a broken =dup that returns nil.
type
  Handle = object
    data: ptr int

proc `=destroy`*(x: Handle) =
  if x.data != nil:
    dealloc(x.data)

proc `=wasMoved`*(x: var Handle) =
  x.data = nil

proc `=copy`*(dest: var Handle; src: Handle) {.error.}
proc `=dup`*(src: Handle): Handle {.error.}

proc newHandle(val: int): Handle =
  result.data = create(int)
  result.data[] = val

proc main() =
  # ensureMove on last-use var — canonical move-only pattern
  var a = newHandle(42)
  var b = ensureMove(a)
  doAssert b.data[] == 42

  # ensureMove on rvalue
  var c = ensureMove(newHandle(99))
  doAssert c.data[] == 99

  # Overwrite with ensureMove on last-use var
  var d = newHandle(7)
  d = ensureMove(b)
  doAssert d.data[] == 42

  echo "C53: PASS"

main()
