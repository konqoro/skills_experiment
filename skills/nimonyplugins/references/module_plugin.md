# Module Plugin

This example preserves a complete module with the low-level cursor API.

```nim
# app.nim
{.plugin: "modulepass".}
echo "kept"
```

```nim
# modulepass.nim
import plugins

let root = loadPluginInput()
if root.stmtKind != StmtsS:
  saveTree errorTree("expected a module statement list", root)
else:
  let rootInfo = root.info
  var statements = firstChild(root)
  var output = createTree()
  output.withTree StmtsS, rootInfo:
    while statements.hasMore:
      output.takeTree statements
  saveTree move output
```

## Key points

- A module plugin receives a semantically checked full module.
- It must return the full module, including unchanged statements.
- Its output is not semantically checked again.

## When to use

Use a module plugin for whole-module auditing, instrumentation, or lowering.
