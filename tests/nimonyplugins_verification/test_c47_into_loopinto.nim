# Test C47: into, loopInto, hasMore traversal templates
import std/[syncio, assertions]
import plugins

var t = createTree()
t.withTree(StmtsS, NoLineInfo):
  t.addIdent "a"
  t.withTree(CallX, NoLineInfo):
    t.addIdent "f"
    t.addStrLit "arg"
  t.addIdent "c"

var n = snapshot(t)
assert n.stmtKind == StmtsS

# into: enter node, process children, advance past )
var count = 0
into n:
  while n.hasMore:
    count += 1
    skip n
assert count == 3  # "a", CallX, "c"

# loopInto: enter and iterate all children (body must advance n)
var t2 = createTree()
t2.withTree(CallX, NoLineInfo):
  t2.addIdent "fn"
  t2.addStrLit "x"
  t2.addIntLit 1

var n2 = snapshot(t2)
assert n2.exprKind == CallX

var childCount = 0
loopInto n2:
  childCount += 1
  skip n2
assert childCount == 3  # fn, "x", 1

echo "C47: PASS"
