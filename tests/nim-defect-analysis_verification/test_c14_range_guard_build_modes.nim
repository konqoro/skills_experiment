import std/assertions

proc acceptPositive(value: Positive): int =
  value

let raw = 0

when compileOption("rangeChecks"):
  doAssertRaises RangeDefect:
    discard Positive(raw)

  doAssertRaises RangeDefect:
    discard acceptPositive(raw)
else:
  doAssert Positive(raw).int == 0
  doAssert acceptPositive(raw) == 0

echo "C14: PASS"
