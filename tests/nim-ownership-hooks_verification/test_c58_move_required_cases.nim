# C58: move() eliminates the copy for var-param fields and loop-indexed
# elements — the exact cases where last-use auto-sink does not fire.

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

proc takeVarParamFieldMove(c: var Created) =
  consume(move(c.remote))        # 0 copies with move

proc loopMove() =
  var rows = @[Shard(s: "a", bytes: 1), Shard(s: "b", bytes: 2)]
  for i in 0..<rows.len:
    consume(move(rows[i]))       # 0 copies with move

proc report(label: string) =
  echo label, ": ", copies, " copy"
  copies = 0

proc main() =
  var c = Created(remote: Shard(s: "p", bytes: 1))
  takeVarParamFieldMove(c)

  report("var param field (move)")
  doAssert copies == 0, "move on var param field should not copy"

  loopMove()

  report("seq loop (move)")
  doAssert copies == 0, "move on loop-indexed element should not copy"

  echo "C58: PASS"

main()
