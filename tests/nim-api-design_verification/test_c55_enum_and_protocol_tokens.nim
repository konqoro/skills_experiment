## C55: closed choices use enums; bounded codes reserve members; extensible
## protocol tokens pass through as strings.

type
  AccessMode = enum
    amRead = "read"
    amWrite = "write"

  WireCode = enum
    wcNone = (0, "none")
    wcGzip = (1, "gzip")
    wcReserved2 = (2, "reserved-2")

  CommonHttpMethod = enum
    hmGet = "GET"
    hmOptions = "OPTIONS"

  RequestSpec = object
    verb: string

proc setAccess(mode: AccessMode): string =
  $mode

proc requestWith(verb: sink string): RequestSpec =
  RequestSpec(verb: verb)

proc requestWith(verb: CommonHttpMethod): RequestSpec =
  requestWith($verb)

# A closed choice accepts declared enum members, not arbitrary strings.
doAssert setAccess(amRead) == "read"
doAssert not compiles(setAccess("read"))

# A bounded wire-code enum can reserve a stable future assignment.
doAssert ord(wcReserved2) == 2
doAssert $wcReserved2 == "reserved-2"

# An extensible protocol token remains unchanged; common tokens may use an enum overload.
doAssert requestWith("PROPFIND").verb == "PROPFIND"
doAssert requestWith(hmOptions).verb == "OPTIONS"

echo "C55: PASS"
