## A move-only wrapper rejects sink assignment after construction.

type
  Handle = object
    raw: ptr int

proc `=destroy`(handle: Handle) =
  if handle.raw != nil:
    dealloc(handle.raw)

proc `=wasMoved`(handle: var Handle) =
  handle.raw = nil

proc `=sink`(dest: var Handle; src: Handle) {.error.}
proc `=copy`(dest: var Handle; src: Handle) {.error.}
proc `=dup`(src: Handle): Handle {.error.}

proc newHandle(): Handle =
  Handle(raw: cast[ptr int](alloc0(sizeof(int))))

proc exercise =
  var handle = newHandle()
  doAssert handle.raw != nil

  var source = newHandle()
  var moved = ensureMove(source)
  doAssert moved.raw != nil

exercise()

when defined(trySink):
  var dest = newHandle()
  dest = newHandle()

echo "C57: PASS"
