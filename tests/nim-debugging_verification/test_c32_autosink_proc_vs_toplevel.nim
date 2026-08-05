# C32: Last-use auto-sink analysis fires inside named procs but NOT at
# module top level. Measuring copy/destructor counts at top level
# misreports every case because the compiler does not apply last-use
# analysis there. This is a measurement hazard for ARC/ORC investigations.

type
  Shard = object
    s: string
    bytes: int

var copies = 0

proc `=copy`(dst: var Shard; src: Shard) =
  inc copies
  dst.s = src.s
  dst.bytes = src.bytes

proc consume(x: sink Shard) =
  discard x.bytes

# Inside a proc: let local at last use auto-sinks (0 copies).
proc inProc(): int =
  copies = 0
  let a = Shard(s: "p", bytes: 1)
  consume(a)
  return copies

# Top-level: the same pattern copies because last-use analysis is off.
let topResult = inProc()
doAssert topResult == 0, "inside a proc, last-use let local should auto-sink"

copies = 0
let b = Shard(s: "t", bytes: 1)
consume(b)
doAssert copies == 1, "at top level, last-use analysis does not fire"

echo "C32: inProc=", topResult, " topLevel=", copies
echo "C32: PASS"
