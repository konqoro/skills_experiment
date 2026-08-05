# C59: Module top-level code never auto-sinks. The same pattern that moves
# inside a proc copies at top level. Measure inside a proc.

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

# This is module top-level. A let local passed to consume here COPIES
# because last-use analysis does not fire at top level.
let a = Shard(s: "x", bytes: 1)
consume(a)

doAssert copies == 1, "top-level let should copy, not auto-sink"
echo "C59: top-level copies = ", copies

echo "C59: PASS"
