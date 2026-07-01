# Test C10, C45, C46: skip and bounded firstChild/hasMore traversal.
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
assert child.kind == StrLit  # "hello"
skip child  # past StrLit
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

echo "C10_C45_C46: PASS"
