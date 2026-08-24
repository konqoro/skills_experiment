# C53 companion: an explicit =dup {.error.} must reject duplication.

type Handle = object
  data: ptr int

proc `=destroy`(x: Handle) =
  if x.data != nil:
    dealloc(x.data)

proc `=wasMoved`(x: var Handle) =
  x.data = nil

proc `=copy`(dst: var Handle; src: Handle) {.error.}
proc `=dup`(src: Handle): Handle {.error.}

var source: Handle
discard `=dup`(source)
