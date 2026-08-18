# C57: Inside a proc, last-use auto-sink fires for let/var locals, their
# fields, tuples, and direct-indexed seq/array elements (0 copies).
# It does NOT fire for var parameters, their fields, or loop-indexed elements.

type
  Shard = object
    s: string
    bytes: int
  Created = object
    remote: Shard

var copies = 0

proc `=copy`(dst: var Shard; src: Shard) =
  inc copies
  dst.s = src.s
  dst.bytes = src.bytes

proc consume(x: sink Shard) =
  discard x.bytes

proc asParam(c: var Created) =
  consume(c.remote)              # 1 copy (var param field)

proc wholeVarParam(x: var Shard) =
  consume(x)                     # 1 copy (whole var param)

proc run(report: proc (label: string)) =
  # let local -> 0
  let a = Shard(s: "x", bytes: 1)
  consume(a)

  # var local field -> 0
  var c = Created(remote: Shard(s: "y", bytes: 1))
  consume(c.remote)

  doAssert copies == 0, "let/var-local field should auto-sink"
  report("let local / var-local field")

  # tuple field -> 0
  var t = (f: Shard(s: "z", bytes: 1), g: Shard(s: "w", bytes: 2))
  consume(t.f)
  var u: (Shard, Shard) = (Shard(s: "a", bytes: 1), Shard(s: "b", bytes: 2))
  consume(u[0])

  doAssert copies == 0, "tuple field/index should auto-sink"
  report("tuple field / tuple[0]")

  # direct array index -> 0
  var arr: array[2, Shard] = [Shard(s: "a", bytes: 1), Shard(s: "b", bytes: 2)]
  consume(arr[0])

  doAssert copies == 0, "direct array index should auto-sink"
  report("array arr[0] direct")

  # seq element in loop -> copies
  var rows = @[Shard(s: "a", bytes: 1), Shard(s: "b", bytes: 2)]
  for i in 0..<rows.len:
    consume(rows[i])

  doAssert copies == 2, "loop-indexed seq element should copy"
  report("seq element in loop")

  # var param field -> 1 copy
  var c2 = Created(remote: Shard(s: "y", bytes: 1))
  asParam(c2)

  doAssert copies == 1, "var param field should copy"
  report("var param field")

  # whole var param -> 1 copy
  var c3 = Shard(s: "y", bytes: 1)
  wholeVarParam(c3)

  doAssert copies == 1, "whole var param should copy"
  report("whole var param")

  echo "C57: PASS"

proc reportImpl(label: string) =
  echo label, ": ", copies, " copy"
  copies = 0

run(reportImpl)
