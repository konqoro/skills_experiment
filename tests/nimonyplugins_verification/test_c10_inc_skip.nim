# Test C10: skip skips whole subtree; firstChild + hasMore for token stepping
import std/[syncio, assertions]
import plugins

var t = createTree()
t.withTree(CallX, NoLineInfo):
  t.addIdent "echo"
  t.addStrLit "hello"

var n = snapshot(t)
assert n.exprKind == CallX

# Use firstChild to get bounded cursor into children
var child = firstChild(n)
assert child.kind == Ident  # "echo"
assert child.identText == "echo"
skip child  # past Ident (atom skip = one token)
assert child.kind == StringLit  # "hello"
skip child  # past StringLit
assert not child.hasMore  # end of children

# Now test skip on a fresh tree with nested structure
var t2 = createTree()
t2.withTree(StmtsS, NoLineInfo):
  t2.withTree(CallX, NoLineInfo):
    t2.addIdent "foo"
  t2.withTree(CallX, NoLineInfo):
    t2.addIdent "bar"

var n2 = snapshot(t2)
assert n2.stmtKind == StmtsS
var body = firstChild(n2)
# now at first CallX child
assert body.exprKind == CallX
skip body  # skips entire CallX subtree
# now at second CallX
assert body.exprKind == CallX
skip body
assert not body.hasMore  # end of StmtsS body

echo "C10: PASS"
