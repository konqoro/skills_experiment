type
  DriverStatus* = enum
    driverOk,
    driverBindFailed,
    driverQueryFailed,
    driverMissingBinding,
    driverRunFailed

  RawBuffer* = ref object
    handle*: uint
    storage*: seq[byte]

  RawNetwork* = ref object
    mode: string
    inputs: seq[RawBuffer]

var
  nextHandle = 1'u
  zeroByte: byte
  bindCalls: int
  queryCalls: int
  mapCalls: int
  runCalls: int

proc resetDriverCounters*() =
  bindCalls = 0
  queryCalls = 0
  mapCalls = 0
  runCalls = 0

proc driverCounters*(): tuple[binds, queries, maps, runs: int] =
  (bindCalls, queryCalls, mapCalls, runCalls)

proc statusMessage*(status: DriverStatus): string =
  case status
  of driverOk: "success"
  of driverBindFailed: "binding failed"
  of driverQueryFailed: "tensor query failed"
  of driverMissingBinding: "input binding missing"
  of driverRunFailed: "network execution failed"

proc initRawNetwork*(mode: string; inputCount: Natural): RawNetwork =
  RawNetwork(mode: mode, inputs: newSeq[RawBuffer](inputCount))

proc initRawBuffer*(capacity: Natural): RawBuffer =
  result = RawBuffer(handle: nextHandle, storage: newSeq[byte](capacity))
  inc nextHandle

proc rawCapacity*(buffer: RawBuffer): int =
  buffer.storage.len

proc bindRawInput*(network: RawNetwork; index: int;
    buffer: RawBuffer): DriverStatus =
  ## The returned status is the only failure channel.
  inc bindCalls
  if network.mode == "bind-fail" or index < 0 or index >= network.inputs.len:
    return driverBindFailed
  network.inputs[index] = buffer
  driverOk

proc queryRawTensor*(network: RawNetwork; rank: var uint32;
    dimensions: var array[4, uint32]): DriverStatus =
  ## On driverOk, rank is in 1..4 and each reported dimension is positive.
  ## On failure, output arguments have no usable value.
  inc queryCalls
  if network.mode == "query-fail":
    return driverQueryFailed
  rank = 2
  dimensions[0] = 3
  dimensions[1] = 4
  driverOk

proc mapRawBuffer*(buffer: RawBuffer): ptr UncheckedArray[byte] =
  ## Requires a bound buffer. Returns storage accessible for rawCapacity bytes.
  ## This operation has no failure result.
  inc mapCalls
  if buffer.storage.len == 0:
    return cast[ptr UncheckedArray[byte]](addr zeroByte)
  cast[ptr UncheckedArray[byte]](addr buffer.storage[0])

proc runRawNetwork*(network: RawNetwork): DriverStatus =
  ## Reports missing bindings and execution failures through its status.
  inc runCalls
  for buffer in network.inputs:
    if buffer == nil or buffer.handle == 0:
      return driverMissingBinding
  if network.mode == "run-fail":
    return driverRunFailed
  driverOk
