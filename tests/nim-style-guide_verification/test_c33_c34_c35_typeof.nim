import std/assertions

iterator resultKind(value: string): char =
  for item in value:
    yield item

proc resultKind(value: string): int =
  value.len

var value = 0

doAssert typeof(value) is int
doAssert type(value) is int
doAssert typeof(resultKind("nim")) is char
doAssert typeof(resultKind("nim"), typeOfProc) is int

echo "C33-C35: PASS"
