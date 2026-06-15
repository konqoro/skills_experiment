# Test C12: add(t, childTree) appends another whole NifBuilder
import std/[syncio, assertions]
import plugins

var child = createTree()
child.addIdent "hello"

var parent = createTree()
parent.withTree(StmtsS, NoLineInfo):
  parent.add(child)

assert not parent.isEmpty

echo "C12: PASS"
