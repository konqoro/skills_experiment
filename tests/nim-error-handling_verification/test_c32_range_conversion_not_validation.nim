import std/assertions

let raw = 0

when compileOption("rangeChecks"):
  var caughtAsCatchable = false
  var caughtAsRangeDefect = false

  try:
    try:
      discard Positive(raw)
    except CatchableError:
      caughtAsCatchable = true
  except RangeDefect:
    caughtAsRangeDefect = true

  doAssert not caughtAsCatchable
  doAssert caughtAsRangeDefect

echo "C32: PASS"
