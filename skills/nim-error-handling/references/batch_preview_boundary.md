# Batch Failure Boundary

Records per-item processing failures at a batch boundary; if the recording path fails, that failure escapes.

```nim
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
```

## Key points

- `process` stays straight-line and lets failures propagate.
- `runBatch` converts processing failures into ordered per-item outcomes.
- If `record` fails, the error escapes `runBatch` — the batch cannot safely report that item.
