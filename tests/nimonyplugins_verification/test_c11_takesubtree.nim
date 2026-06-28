# Test C11: takeTree advances, addSubtree does not
import std/[syncio, assertions]
import plugins

var src = createTree()
src.withTree(StmtsS, NoLineInfo):
  src.addIdent "a"
  src.addIdent "b"

var n = snapshot(src)
var reader = firstChild(n)  # bounded cursor past StmtsS TagLit

# addSubtree does not advance
var dest1 = createTree()
dest1.addSubtree(reader)
assert reader.identText == "a"  # still at "a"

# takeTree advances
var dest2 = createTree()
dest2.takeTree(reader)
assert reader.hasMore  # now at "b"
assert reader.identText == "b"

echo "C11: PASS"
