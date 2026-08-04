## C43: a getter/setter pair may share the name of the field it wraps.
## Inside this module, dot access reaches the field; from outside, it reaches
## the accessors, provided the field is not visible there.

type
  Socket* = object
    host: int            # private: outside callers route through accessors

  Open* = object
    val*: int            # visible: dot access wins, setter is bypassed

var socketGetCalls* = 0
var socketSetCalls* = 0
var openSetCalls* = 0

proc `host=`*(s: var Socket, value: int) {.inline.} =
  socketSetCalls.inc
  s.host = value

proc host*(s: Socket): int {.inline.} =
  socketGetCalls.inc
  s.host

# Inside the module, `s.host` must be field access, not an accessor call.
proc fieldRead*(s: Socket): int = s.host
proc fieldWrite*(s: var Socket, v: int) = s.host = v

proc `val=`*(s: var Open, value: int) {.inline.} =
  openSetCalls.inc
  s.val = value

proc val*(s: Open): int {.inline.} =
  s.val
