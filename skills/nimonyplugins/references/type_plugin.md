# Type Plugin

This example reads triggering type definitions and preserves the full module.

```nim
# traceable.nim
type Traceable* {.plugin: "traceplug".} = object
  id*: int
```

```nim
# traceplug.nim
import plugins

let moduleRoot = loadPluginInput()
let definitions = loadTypeDefinitions()
if definitions.stmtKind != StmtsS:
  saveTree errorTree("expected triggering type definitions", definitions)
elif moduleRoot.stmtKind != StmtsS:
  saveTree errorTree("expected a module statement list", moduleRoot)
else:
  discard renderNode(definitions) # inspect fields before deciding the rewrite
  let rootInfo = moduleRoot.info
  var statements = firstChild(moduleRoot)
  var output = createTree()
  output.withTree StmtsS, rootInfo:
    while statements.hasMore:
      output.takeTree statements
  saveTree move output
```

## Key points

- `loadPluginInput()` reads the full module.
- `loadTypeDefinitions()` reads `(stmts <triggering-type-symbols...>)`.
- Return the complete module; type-plugin output is not checked again.

## When to use

Use a type plugin when a marked type should affect modules that use it.
