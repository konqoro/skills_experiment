# Test: move_only_resource.md reference compiles and works
# Simulated C API using alloc/dealloc instead of real importc
{.push checks: off.}
type
  RawHandle = object
    w: cint
    h: cint

proc libCreate(width, height: cint): ptr RawHandle =
  result = cast[ptr RawHandle](alloc0(sizeof(RawHandle)))
  result.w = width
  result.h = height

proc libDestroy(h: ptr RawHandle) =
  if h != nil: dealloc(h)

type
  Handle = object
    raw: ptr RawHandle

proc `=destroy`(h: Handle) =
  if h.raw != nil:
    libDestroy(h.raw)

proc `=wasMoved`(h: var Handle) =
  h.raw = nil

proc `=sink`(dest: var Handle; src: Handle) {.error.}
proc `=copy`(dest: var Handle; src: Handle) {.error.}
proc `=dup`(src: Handle): Handle {.error.}
{.pop.}

proc initHandle(width, height: int): Handle =
  let raw = libCreate(cint(width), cint(height))
  if raw == nil:
    raise newException(ValueError, "Failed to create handle")
  Handle(raw: raw)

proc main =
  var first = initHandle(640, 480)
  var handle = ensureMove(first)
  doAssert handle.raw != nil
  doAssert handle.raw.w == 640
  doAssert handle.raw.h == 480
main()

echo "ref_move_only: PASS"
