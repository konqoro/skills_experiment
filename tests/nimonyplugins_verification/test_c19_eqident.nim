# Test C19: eqIdent exact-name check
import std/[syncio, assertions]
import plugins

var t = createTree()
t.addIdent "myName"
var n = snapshot(t)
assert n.eqIdent("myName")
assert not n.eqIdent("otherName")

echo "C19: PASS"
