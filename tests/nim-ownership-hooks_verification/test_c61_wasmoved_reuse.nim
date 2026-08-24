# C61: A moved-from owner must be safe to reuse, not merely safe to destroy.
# Compile normally for the correct hook. Compile with -d:buggy to reproduce the
# stale-metadata failure that a destroy-only test misses.

type
  Writer = object
    data: ptr UncheckedArray[char]
    pos: int
    capacity: int

proc `=destroy`(w: Writer) =
  if w.data != nil:
    dealloc(w.data)

proc `=wasMoved`(w: var Writer) =
  w.data = nil
  when not defined(buggy):
    w.pos = 0
    w.capacity = 0

proc `=copy`(dst: var Writer; src: Writer) {.error.}
proc `=dup`(src: Writer): Writer {.error.}

proc reserve(w: var Writer; extra: int) =
  let required = w.pos + extra
  if required > w.capacity:
    let newCap = max(required, 64)
    w.data = cast[ptr UncheckedArray[char]](realloc(w.data, newCap))
    w.capacity = newCap

proc writeByte(w: var Writer; c: char) =
  w.reserve(1)
  w.data[w.pos] = c
  inc w.pos

proc keepAlive(w: var Writer): int = w.pos

proc main =
  var a = Writer()
  for _ in 0..<32:
    a.writeByte 'x'

  var b = move(a)
  b.writeByte 'y'
  discard b.keepAlive()

  a.writeByte 'z'
  doAssert a.pos == 1
  doAssert a.capacity == 64
  doAssert a.data != nil

main()
echo "C61: PASS"
