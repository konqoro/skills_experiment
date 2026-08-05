# C60: ensureMove on a sink argument that the compiler cannot prove is last
# use is a COMPILE ERROR ("introduces an implicit copy"). ensureMove is for
# return positions and must-fail-instead-of-copy cases, not routine sink
# arguments.

type
  Shard = object
    s: string
    bytes: int

proc `=copy`(dst: var Shard; src: Shard) =
  dst.s = src.s
  dst.bytes = src.bytes

proc consume(x: sink Shard) =
  discard x.bytes

proc run() =
  var rows = @[Shard(s: "a", bytes: 1), Shard(s: "b", bytes: 2)]
  for i in 0..<rows.len:
    consume(ensureMove(rows[i]))   # compile error

run()
