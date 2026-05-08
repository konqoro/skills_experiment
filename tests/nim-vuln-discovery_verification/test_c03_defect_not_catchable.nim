proc raiseIndexDefect() =
  raise newException(IndexDefect, "simulated index defect")

var caughtCatchable = false
var caughtDefect = false

try:
  try:
    raiseIndexDefect()
  except CatchableError:
    caughtCatchable = true
except IndexDefect:
  caughtDefect = true

doAssert not caughtCatchable
doAssert caughtDefect
echo "C03: PASS"
