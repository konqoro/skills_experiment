# Test: C37 - a failed condition is either recoverable or a programming bug,
# never both.
import std/assertions

# Bad pattern: diagnostic context changes the failure category.
# `total == 0` is reported as a catchable ValueError when a message is
# supplied, and as an AssertionDefect (programming bug) otherwise.
proc weightedIndexBad(weights: openArray[int]; errorMessage = ""): int =
  var total = 0
  for weight in weights:
    total += weight

  if total == 0:
    if errorMessage.len > 0:
      raise newException(ValueError, errorMessage)
    assert false, "weighted pool has no positive weight"

  result = 0

# With a message, the same failed condition is reported as recoverable:
# it is caught by `except ValueError`.
var caughtValue = false
try:
  discard weightedIndexBad([0, 0], "no weight")
except ValueError:
  caughtValue = true
doAssert caughtValue

# Without a message, the same failed condition is reported as a programming
# bug: it raises AssertionDefect, which escapes `except CatchableError`.
var caughtValue2 = false
var caughtAssertion = false
try:
  try:
    discard weightedIndexBad([0, 0])
  except ValueError:
    caughtValue2 = true
except AssertionDefect:
  caughtAssertion = true
doAssert not caughtValue2
doAssert caughtAssertion

# Same input, same condition, two different failure categories:
# the diagnostic context flipped the condition from recoverable to bug.
# This is the violation the rule forbids.

# Good pattern: when validation guarantees a positive total, `total == 0`
# can never be valid caller input, so it is always a programming bug.
# Diagnostic context only customizes the message; it never changes the
# failure category.
proc weightedIndexGood(weights: openArray[int];
                       errorMessage = "weighted pool has no positive weight"): int =
  var total = 0
  for weight in weights:
    total += weight

  assert total > 0, errorMessage
  result = 0

var goodBugReported = false
try:
  try:
    discard weightedIndexGood([0, 0], "custom message")
  except ValueError:
    doAssert false, "a bug must not become recoverable because a message is supplied"
except AssertionDefect:
  goodBugReported = true
doAssert goodBugReported

echo "C37: PASS"