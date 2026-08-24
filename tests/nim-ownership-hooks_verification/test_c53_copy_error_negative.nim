# C53 boundary companion: omitting =dup does not bypass =copy {.error.} for an
# ordinary copy that is not a last read.

type Handle = object
  data: ptr int

proc `=destroy`(x: Handle) =
  if x.data != nil:
    dealloc(x.data)

proc `=wasMoved`(x: var Handle) =
  x.data = nil

proc `=copy`(dst: var Handle; src: Handle) {.error.}

var source: Handle
var duplicate = source
discard source.data
discard duplicate.data
