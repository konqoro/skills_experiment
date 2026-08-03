import std/os

import fixtures/fake_driver
import subject_solution

template expectError(errorType: typedesc; body: untyped) =
  block:
    var raised = false
    try:
      body
    except errorType:
      raised = true
    doAssert raised

resetDriverCounters()

var network = initNetwork()
network.bindInput(0, 4)
let buffer = network.input(0)

buffer.write([1'u8, 2, 3, 4, 5, 6])
doAssert buffer.contents == @[1'u8, 2, 3, 4]
buffer.write([])
doAssert buffer.contents == @[1'u8, 2, 3, 4]

expectError(ValueError):
  discard network.input(1)
expectError(IndexDefect):
  discard network.input(2)

doAssert network.tensorInfo.dimensions == @[3, 4]
expectError(BackendError):
  network.run()
doAssert driverCounters().runs == 1

network.bindInput(1, 2)
network.run()
doAssert driverCounters().runs == 2

var bindFailure = initNetwork("bind-fail")
expectError(BackendError):
  bindFailure.bindInput(0, 1)

let queryFailure = initNetwork("query-fail")
expectError(BackendError):
  discard queryFailure.tensorInfo()

var runFailure = initNetwork("run-fail")
runFailure.bindInput(0, 1)
runFailure.bindInput(1, 1)
expectError(BackendError):
  runFailure.run()

writeFile("judge-exact.bin", "WXYZ")
buffer.loadTensorFile("judge-exact.bin")
doAssert buffer.contents == @['W'.byte, 'X'.byte, 'Y'.byte, 'Z'.byte]

writeFile("judge-wrong.bin", "too long")
expectError(ValueError):
  buffer.loadTensorFile("judge-wrong.bin")
doAssert buffer.contents == @['W'.byte, 'X'.byte, 'Y'.byte, 'Z'.byte]

removeFile("judge-exact.bin")
removeFile("judge-wrong.bin")
echo "JUDGE: PASS"
