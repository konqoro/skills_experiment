Choose state scope based on whether mutation belongs to one local operation or
spans several orchestration steps.

```nim
type
  WriteState = object
    nextToWrite: int

proc flushReady(state: var WriteState; total: int) =
  if state.nextToWrite < total:
    inc state.nextToWrite

proc runShared(total: int): int =
  var state: WriteState
  while state.nextToWrite < total:
    flushReady(state, total)
  result = state.nextToWrite

proc runLocal(total: int): int =
  var nextToWrite = 0

  proc flushReady() =
    if nextToWrite < total:
      inc nextToWrite

  while nextToWrite < total:
    flushReady()
  result = nextToWrite

doAssert runShared(10) == 10
doAssert runLocal(10) == 10
```

### Key points

- Both patterns compile and run correctly under ORC.
- A short closure is appropriate when its state and use remain local to one
  operation.
- An explicit state object makes mutation shared by several steps visible in
  their proc signatures.
- Choose based on state lifetime and invariant scope, not a blanket ban on
  nested procs.
