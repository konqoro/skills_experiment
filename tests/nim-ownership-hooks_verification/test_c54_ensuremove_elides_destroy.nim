# C54: ensureMove elides the source's =destroy.
# Compiler lowers ensureMove to raw assignment + =wasMoved;
# source is excluded from finally-block destructor list.
type
  Handle = object
    data: ptr int

var destroyCount = 0

proc `=destroy`*(x: Handle) =
  if x.data != nil:
    dealloc(x.data)
  inc destroyCount

proc `=wasMoved`*(x: var Handle) = x.data = nil
proc `=copy`*(dest: var Handle; src: Handle) {.error.}
proc `=dup`*(src: Handle): Handle {.error.}

proc newHandle(v: int): Handle =
  result.data = create(int)
  result.data[] = v

proc main() =
  # ensureMove: source destroy should NOT run
  block:
    destroyCount = 0
    var a = newHandle(42)
    var b = ensureMove(a)
    # If ensureMove elided the destroy, destroyCount should be 0
    # (b's destroy runs at scope exit, but that's the destination)
    doAssert b.data[] == 42
  # b went out of scope — that's one destroy
  doAssert destroyCount == 1, "expected 1 destroy (b only), got " & $destroyCount

  # move: source destroy DOES run
  block:
    destroyCount = 0
    var a = newHandle(99)
    var b = move(a)
    doAssert b.data[] == 99
  # b destroyed (1), a also destroyed (1) — total 2
  doAssert destroyCount == 2, "expected 2 destroys (a + b), got " & $destroyCount

  echo "C54: PASS"

main()
