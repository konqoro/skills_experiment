# Template Plugin

This example validates the template protocol and generates a compile-time table.

```nim
# tableapi.nim
template squares*(): untyped {.plugin: "squareplug".}
```

```nim
# squareplug.nim
import plugins

let root = loadPluginInput()
if pluginName(root) != "squares" or callArgs(root).hasMore:
  saveTree errorTree("squares takes no arguments", root)
else:
  var output = createTree()
  output.withTree BracketX, root.info:
    for value in 0..15:
      output.addIntLit(value * value)
  saveTree move output
```

```nim
# app.nim
import tableapi
let table: array[16, int] = squares()
assert table[5] == 25
```

## Key points

- Input is `(stmts <template-name> <args...>)`.
- Use `pluginName` and `callArgs`, even for a zero-argument template.
- Template output is semantically checked after substitution.

## When to use

Use a template plugin for a call-site rewrite or synthetic expression.
