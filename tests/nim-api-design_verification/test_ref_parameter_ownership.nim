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

example()
echo "ref_parameter_ownership: PASS"
