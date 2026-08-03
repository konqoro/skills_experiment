# Test: C36 - assert for conditions whose failure means a programming bug
import std/assertions

when compileOption("assertions"):
  import std/strutils

when compileOption("assertions"):
  # A failing assert raises AssertionDefect, a Defect, so it escapes
  # `except CatchableError` boundaries: it is a bug guard, not a
  # recoverable validation channel.
  var caughtAsCatchable = false
  var caughtAsAssertionDefect = false
  var msg = ""
  try:
    try:
      assert false, "next called before open"
    except CatchableError:
      caughtAsCatchable = true
  except AssertionDefect as e:
    caughtAsAssertionDefect = true
    msg = e.msg

  doAssert not caughtAsCatchable
  doAssert caughtAsAssertionDefect
  doAssert "next called before open" in msg

  # State-guard form from the skill example: assert s.opened, "..."
  type Session = object
    opened: bool
  var s = Session(opened: false)
  var stateGuard = false
  try:
    assert s.opened, "next called before open"
  except AssertionDefect:
    stateGuard = true
  doAssert stateGuard

else:
  # With --assertions:off the assert is a no-op, so it cannot be used as
  # runtime validation for recoverable failures.
  var notFired = true
  try:
    assert false, "disabled"
  except AssertionDefect:
    notFired = false
  doAssert notFired

echo "C36: PASS"
