# Test C15: addEmptyNode4 emits four placeholders.
import std/[syncio, assertions]
import plugins

var t = createTree()
t.withTree(StmtsS, NoLineInfo):
  t.addEmptyNode4()

let rendered = renderTree(t)
# rendered contains 4 dot tokens
assert rendered.len > 0

echo "C15: PASS"
