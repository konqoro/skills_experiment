# Test C48: copyInto structured copy
import std/[syncio, assertions]
import plugins

# Build a source tree with nested structure
var src = createTree()
src.withTree(StmtsS, NoLineInfo):
  src.addIdent "kept"
  src.withTree(CallX, NoLineInfo):
    src.addIdent "echo"
    src.addStrLit "hello"

var n = snapshot(src)
assert n.stmtKind == StmtsS

# copyInto: copy tag to output, process children, close both
var dest = createTree()
dest.copyInto(n):
  while n.hasMore:
    dest.takeTree n

assert not dest.isEmpty
let rendered = renderTree(dest)
assert rendered.len > 0

echo "C48: PASS"
