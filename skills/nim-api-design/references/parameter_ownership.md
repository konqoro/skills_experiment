# Parameter Ownership

Complete example choosing parameter modes from caller-visible ownership behavior.

```nim
type
  Job* = object
    name*: string
    payload*: seq[byte]

  JobQueue* = object
    jobs: seq[Job]

proc payloadLen*(job: Job): int =
  job.payload.len

proc rename*(job: var Job; name: string) =
  job.name = name

proc add*(queue: var JobQueue; job: sink Job) =
  queue.jobs.add job

proc last*(queue: JobQueue): lent Job =
  queue.jobs[queue.jobs.high]

proc example() =
  var queue: JobQueue
  queue.add Job(name: "temporary", payload: @[1'u8])

  var retained = Job(name: "retained", payload: @[2'u8])
  queue.add retained
  doAssert retained.name == "retained"

  var transferred = Job(name: "transferred", payload: @[3'u8])
  queue.add transferred
  doAssert queue.last.name == "transferred"

when isMainModule:
  example()
```

## Key points

- Use `T` for read-only input and `var T` only for caller-visible mutation.
- Use `sink T` when the callee stores, forwards, or otherwise takes ownership of the value.
- A retained sink argument may be copied; a temporary can move directly.
- Use `lent T` only for a borrowed return tied to storage owned by the receiver.
- Pass routine sink arguments normally. Use `ensureMove` only when a possible copy must be a compile-time error.
