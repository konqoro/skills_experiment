import std/assertions

when defined(danger):
  let raw = 0
  doAssert Positive(raw).int == 0
else:
  let raw = 0
  var raised = false
  try:
    discard Positive(raw)
  except RangeDefect:
    raised = true
  doAssert raised

echo "C32: PASS"
