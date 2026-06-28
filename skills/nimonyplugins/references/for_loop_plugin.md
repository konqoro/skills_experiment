# For-Loop Plugin

This example validates structured for-loop input and replaces the loop.

```nim
# loopapi.nim
iterator once*(): int {.plugin: "loopplug".}
```

```nim
# loopplug.nim
import plugins
import std/syncio

let root = loadPluginInput()
if pluginName(root) != "once":
  saveTree errorTree("unexpected iterator plugin", root)
elif forLoopCallArgs(root).otherKind != CallargsU:
  saveTree errorTree("expected call arguments", root)
elif forLoopVars(root).otherKind notin {UnpackflatU, UnpacktupU}:
  saveTree errorTree("expected loop variables", root)
else:
  discard forLoopBody(root) # available as an already typed subtree
  var output = createTree()
  output.withTree StmtsS, root.info:
    output.withTree CallS, root.info:
      output.bindSym "echo"
      output.addStrLit "loop plugin ran"
  saveTree move output
```

```nim
# app.nim
import loopapi
for ignored in once():
  discard
```

## Key points

- Input is `(forcall <name> (callargs ...) (unpack...) <typed-body>)`.
- Use the four protocol helpers instead of positional cursor arithmetic.
- The body is typed before the plugin runs; generated output is checked again.

## When to use

Use a for-loop plugin to unroll or rewrite a loop around an iterator-like DSL.
