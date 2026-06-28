# Replacer API

This example turns `sayIt(x)` into `echo x` while honoring template input shape.

```nim
# sayitapi.nim
template sayIt*(x: untyped): untyped {.plugin: "sayitplug".}
```

```nim
# sayitplug.nim
import plugins

var r = loadReplacer()
replaceHead r, CallS, r.info:
  drop r, Any # consume the leading template name
  r.dest.bindSym "echo"
  while getCursor(r).hasMore:
    keep r, Expr
saveReplacer r
```

Read-only classification uses a copied bounded cursor:

```nim
proc isCallTo(n: NifCursor; name: string): bool =
  if n.kind != TagLit or n.exprKind != CallX:
    return false
  var child = firstChild(n)
  result = child.hasMore and child.eqIdent(name)
```

Operation contracts:

| Operation | Effect |
| --- | --- |
| `keep r, K` | copy and consume one matching child |
| `drop r, K` | consume one matching child |
| `replace r, K, x` | consume one child and emit `x` |
| `keepTag r:` | preserve a head; body consumes every child |
| `loopKeepTag r:` | preserve a head and iterate children |
| `replaceHead r, K, info:` | emit a new head; body consumes every child |

`peek r:` restores the input cursor only. Never emit into `r.dest` inside it.

## Key points

- Expected kinds are assertions, not filters.
- Template input begins with the invoked template name.
- Use `loopKeepTag` for recursive pass-through and `replaceHead` for a new head.
- Use `errorTree` for invalid user input; assertions expose plugin bugs.

## When to use

Use `Replacer` when most input subtrees remain unchanged.
