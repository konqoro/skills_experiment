# C09+C10: Self-sink is eliminated (no hooks called). Self-copy needs protection.
var customSinkCalled = 0

type Buf = object
  data: ptr int

proc `=destroy`*(x: var Buf) =
  if x.data != nil:
    dealloc(x.data)
    x.data = nil

proc `=wasMoved`*(x: var Buf) = x.data = nil

proc `=sink`*(dest: var Buf; src: Buf) =
  customSinkCalled.inc()
  `=destroy`(dest)
  dest.data = src.data

proc `=copy`*(dest: var Buf; src: Buf) =
  if dest.data != src.data:
    `=destroy`(dest)
    `=wasMoved`(dest)
    if src.data != nil:
      dest.data = create(int)
      dest.data[] = src.data[]

proc main() =
  var a: Buf
  a.data = create(int)
  a.data[] = 42
  reset customSinkCalled
  a = a
  echo "C09: customSinkCalled after x=x = ", customSinkCalled
  var b: Buf
  b.data = create(int)
  b.data[] = 99
  b = b
  doAssert b.data[] == 99
  echo "C09+C10: PASS"
main()
