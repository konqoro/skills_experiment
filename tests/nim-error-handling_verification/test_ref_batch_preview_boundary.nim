# Test: batch_preview_boundary.md reference compiles and works

type
  ItemOutcome = object
    input: string
    ok: bool
    errorMsg: string

  BatchResult = object
    succeeded: int
    failed: int
    outcomes: seq[ItemOutcome]

proc process(input: string) =
  if input == "":
    raise newException(ValueError, "empty input")
  if input == "bad":
    raise newException(IOError, "device busy")

proc record(logPath: string; line: string) =
  if logPath == "dead":
    raise newException(IOError, "log device unavailable")

proc runBatch(inputs: seq[string]; logPath: string): BatchResult =
  for input in inputs:
    try:
      process(input)
      result.outcomes.add ItemOutcome(input: input, ok: true)
      inc result.succeeded
    except CatchableError:
      let msg = getCurrentExceptionMsg()
      record(logPath, input & " failed: " & msg)
      result.outcomes.add ItemOutcome(input: input, ok: false, errorMsg: msg)
      inc result.failed

proc main =
  # Test 1: all succeed
  let r1 = runBatch(@["a", "b"], "live")
  doAssert r1.succeeded == 2
  doAssert r1.failed == 0
  doAssert r1.outcomes[0].ok
  doAssert r1.outcomes[1].ok

  # Test 2: mixed success/failure with correct messages
  let r2 = runBatch(@["good", "", "bad"], "live")
  doAssert r2.succeeded == 1
  doAssert r2.failed == 2
  doAssert r2.outcomes[0].ok
  doAssert not r2.outcomes[1].ok
  doAssert r2.outcomes[1].errorMsg == "empty input"
  doAssert not r2.outcomes[2].ok
  doAssert r2.outcomes[2].errorMsg == "device busy"

  # Test 3: recording failure escapes the batch
  var escaped = false
  try:
    discard runBatch(@["good", ""], "dead")
  except IOError:
    escaped = true
    doAssert getCurrentExceptionMsg() == "log device unavailable"
  doAssert escaped

main()
echo "ref_batch_preview_boundary: PASS"
