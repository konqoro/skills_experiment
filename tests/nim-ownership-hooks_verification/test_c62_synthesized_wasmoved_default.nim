# C62: On Nim 2.3.1, this plain zero-default owner gets a synthesized
# =wasMoved that resets both the resource pointer and its paired metadata.

type
  Writer = object
    data: ptr UncheckedArray[char]
    pos: int
    capacity: int

proc `=destroy`(w: Writer) =
  if w.data != nil:
    dealloc(w.data)

proc `=copy`(dst: var Writer; src: Writer) {.error.}
proc `=dup`(src: Writer): Writer {.error.}

proc main =
  var a = Writer(
    data: cast[ptr UncheckedArray[char]](alloc(64)),
    pos: 32,
    capacity: 64)

  var b = move(a)
  doAssert a.data == nil
  doAssert a.pos == 0
  doAssert a.capacity == 0
  doAssert b.data != nil
  doAssert b.pos == 32
  doAssert b.capacity == 64

main()
echo "C62: PASS"
