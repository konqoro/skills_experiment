## C55: public enumerated choices use enum parameters, not string parameters.
## C55: explicit reserved ordinals preserve bounded future protocol codes.

type
  AccessMode = enum
    amRead = (0, "read")
    amWrite = (1, "write")

  WireCompression = enum
    wcNone = (0, "none")
    wcGzip = (1, "gzip")
    wcReserved2 = (2, "reserved-2")
    wcReserved3 = (3, "reserved-3")

proc openAccess(mode: AccessMode): string =
  $mode

proc stringlyOpen(mode: string): string =
  mode

func isSupported(mode: WireCompression): bool =
  mode in {wcNone, wcGzip}

proc decodeCompression(raw: uint8): WireCompression =
  if raw > uint8(ord(high(WireCompression))):
    raise newException(ValueError, "invalid compression code")
  WireCompression(raw)

proc encodeCompression(mode: WireCompression): uint8 =
  uint8(ord(mode))

# The enum parameter accepts declared values but cannot be called with raw strings.
doAssert openAccess(amRead) == "read"
doAssert not compiles(openAccess("read"))
doAssert not compiles(openAccess("truncate-everything"))

# A string parameter provides no equivalent boundary check.
doAssert compiles(stringlyOpen("truncate-everything"))

# Reserved values are valid wire values, preserve their ordinal, and remain unsupported.
let futureCode = decodeCompression(2)
doAssert futureCode == wcReserved2
doAssert encodeCompression(futureCode) == 2
doAssert not futureCode.isSupported
doAssert wcGzip.isSupported

try:
  discard decodeCompression(4)
  doAssert false
except ValueError:
  discard

echo "C55: PASS"
