## C28: Templates are required when proc semantics cannot substitute:
## call-site body injection, lazy evaluation, and control-flow abstraction.

import std/assertions

# A template with an untyped body parameter accepts a code block.
# A proc cannot accept an untyped body.
template withLock(body: untyped) =
  try:
    body
  finally:
    discard

var counter = 0
withLock:
  inc counter
doAssert counter == 1

# A template skips the argument expression entirely when a compile-time
# condition is false. A proc would evaluate the argument before the call.
template debugLog(msg: untyped) =
  when defined(debug):
    echo msg

var sideEffectCount = 0
proc expensiveLog(): string =
  inc sideEffectCount
  "logged"

debugLog(expensiveLog())
doAssert sideEffectCount == 0

echo "C28: PASS"
