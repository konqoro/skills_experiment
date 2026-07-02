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

proc initHandle(): Handle =
  Handle(raw: cast[ptr int](alloc0(sizeof(int))))

proc exercise =
  var handle = initHandle()
  doAssert handle.raw != nil

  var source = initHandle()
  var moved = ensureMove(source)
  doAssert moved.raw != nil

exercise()

when defined(trySink):
  var dest = initHandle()
  dest = initHandle()

echo "C57: PASS"
