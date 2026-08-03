import std/assertions, std/strutils

let raw = 0

when compileOption("rangeChecks"):
  # Direct conversion: invalid value raises RangeDefect, not CatchableError.
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

  # The skill's example: Positive(parseInt(s)) is not recoverable validation.
  var parseCatchable = false
  var parseRangeDefect = false
  try:
    try:
      discard Positive(parseInt("0"))
    except CatchableError:
      parseCatchable = true
  except RangeDefect:
    parseRangeDefect = true

  doAssert not parseCatchable
  doAssert parseRangeDefect

echo "C32: PASS"
