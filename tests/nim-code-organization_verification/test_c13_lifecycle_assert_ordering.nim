# Test: C13 - lifecycle assert guard fires on out-of-order incremental-API calls
when compileOption("assertions"):
  import std/strutils

  type
    WordScanner = object
      input: string
      pos: int
      opened: bool

  proc open(s: var WordScanner; input: string) =
    s = WordScanner(input: input, opened: true)

  proc next(s: var WordScanner): string =
    assert s.opened, "next called before open"
    result = s.input[s.pos..<s.input.len]

  # Default build: next before open raises AssertionDefect, a Defect that
  # escapes `except CatchableError` boundaries. It is a debug-time ordering
  # guard, not runtime validation.
  var caughtAsCatchable = false
  var caughtAsAssertionDefect = false
  var msg = ""
  var scanner: WordScanner
  try:
    try:
      discard scanner.next()
    except CatchableError:
      caughtAsCatchable = true
  except AssertionDefect as e:
    caughtAsAssertionDefect = true
    msg = e.msg

  doAssert not caughtAsCatchable
  doAssert caughtAsAssertionDefect
  doAssert "next called before open" in msg

  scanner.open("data")
  doAssert scanner.next() == "data"

else:
  # With --assertions:off the guard is compiled out: the same out-of-order
  # call must not raise.
  type
    WordScanner = object
      input: string
      pos: int
      opened: bool

  proc open(s: var WordScanner; input: string) =
    s = WordScanner(input: input, opened: true)

  proc next(s: var WordScanner): string =
    assert s.opened, "next called before open"
    result = s.input[s.pos..<s.input.len]

  var scanner: WordScanner
  var fired = false
  try:
    discard scanner.next()
  except AssertionDefect:
    fired = true
  doAssert not fired

  scanner.open("data")
  doAssert scanner.next() == "data"

echo "C13: PASS"
