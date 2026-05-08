when defined(danger):
  assert false

  var caught = false
  try:
    doAssert false
  except AssertionDefect:
    caught = true

  doAssert caught
else:
  doAssert true

echo "C04: PASS"
