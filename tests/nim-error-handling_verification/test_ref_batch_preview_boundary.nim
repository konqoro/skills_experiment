# Test: batch_preview_boundary.md reference compiles and works

import std/strutils, std/os

type
  ParseOutcome = object
    ok: bool
    value: float
    errorMsg: string

  BatchResult = object
    succeeded: int
    failed: int
    outcomes: seq[ParseOutcome]

proc appendLog(logPath: string; line: string) =
  let f = open(logPath, fmAppend)
  f.writeLine(line)
  f.close()

proc runBatch(inputs: seq[string]; logPath: string): BatchResult =
  for input in inputs:
    try:
      let value = parseFloat(input)
      result.outcomes.add ParseOutcome(ok: true, value: value)
      inc result.succeeded
    except ValueError:
      let msg = getCurrentExceptionMsg()
      appendLog(logPath, input & ": " & msg)
      result.outcomes.add ParseOutcome(ok: false, errorMsg: msg)
      inc result.failed

proc main =
  let logPath = getTempDir() / "test_batch_log.txt"
  removeFile(logPath)

  # Test 1: all succeed
  let r1 = runBatch(@["3.14", "2.71"], logPath)
  doAssert r1.succeeded == 2
  doAssert r1.failed == 0
  doAssert r1.outcomes[0].ok
  doAssert r1.outcomes[0].value == 3.14
  doAssert r1.outcomes[1].ok
  doAssert r1.outcomes[1].value == 2.71

  # Test 2: mixed success/failure with correct messages
  let r2 = runBatch(@["3.14", "abc", ""], logPath)
  doAssert r2.succeeded == 1
  doAssert r2.failed == 2
  doAssert r2.outcomes[0].ok
  doAssert not r2.outcomes[1].ok
  doAssert r2.outcomes[1].errorMsg == "invalid float: abc"
  doAssert not r2.outcomes[2].ok
  doAssert r2.outcomes[2].errorMsg == "invalid float: "

  # Test 3: recording failure escapes the batch
  var escaped = false
  try:
    discard runBatch(@["abc"], "/nonexistent/dir/cannot/create/log.txt")
  except IOError:
    escaped = true
  doAssert escaped

  removeFile(logPath)

main()
echo "ref_batch_preview_boundary: PASS"
