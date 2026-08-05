Find an unwanted ownership copy with a `=copy` counter and `--expandArc`, then confirm the fix inside a proc.

```nim
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

proc takeRemote(c: var Created) =
  consume(c.remote)

proc takeRemoteMove(c: var Created) =
  consume(move(c.remote))

proc main =
  copies = 0
  var c = Created(remote: Shard(s: "p", bytes: 1))
  takeRemote(c)
  echo "takeRemote copies: ", copies

  copies = 0
  var c2 = Created(remote: Shard(s: "p", bytes: 1))
  takeRemoteMove(c2)
  echo "takeRemoteMove copies: ", copies

main()
```

Run it, then inspect both procs:

```bash
nim c -r example.nim
nim c --expandArc:takeRemote --expandArc:takeRemoteMove example.nim
```

`takeRemote` prints `1` and its expansion shows `=dup(c.remote)`; the field of a
`var` parameter is not a last use. `takeRemoteMove` prints `0` and its expansion
shows `move(c.remote)`.

## When to use

- Measure inside a named proc. Last-use auto-sink does not fire at module top
  level, so top-level measurements misreport every case as a copy.
- A copy in `--expandArc` appears as `=copy`, `=dup`, or `=dup_<n>`; a move
  appears as `=sink` plus `=wasMoved`.
- See `nim-api-design` for the caller-facing rules on which sink arguments
  auto-sink and which require `move()`.
