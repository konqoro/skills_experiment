## C48: explicit enum string values control `$` and round-trip through parseEnum.
## C49: enum fields can set ordinal and string together via a tuple; ordinals must be ascending.

import std/strutils

type
  Priority = enum
    priLow = "low"
    priNormal = "normal"
    priHigh = "high"

  WireCode = enum
    wcOk = (0, "OK")
    wcRetry = (1, "RETRY")
    wcFatal = (2, "FATAL")

  TokenType = enum
    a = 2, b = 4, c = 89  # holes are valid

# C48: `$` yields the custom string, not the field name.
doAssert $priHigh == "high"
doAssert $wcFatal == "FATAL"

# C48: parseEnum parses the custom string back.
doAssert parseEnum[Priority]("high") == priHigh
doAssert parseEnum[Priority]("low") == priLow

# C48: an unknown string raises unless a default is given.
doAssert parseEnum[Priority]("nope", priLow) == priLow

# C49: tuple form sets ordinal and string together.
doAssert ord(wcOk) == 0
doAssert $wcOk == "OK"
doAssert ord(wcFatal) == 2
doAssert $wcFatal == "FATAL"

# C49: ordinals with holes are valid but the enum is no longer ordinal.
doAssert ord(a) == 2
doAssert ord(c) == 89

echo "C48 C49: PASS"
