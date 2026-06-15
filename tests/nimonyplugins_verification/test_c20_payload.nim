# Test C20: payload readers - symText, identText, stringValue, intValue, etc.
import std/[syncio, assertions]
import plugins

# identText
var t1 = createTree()
t1.addIdent "myIdent"
var n1 = snapshot(t1)
assert n1.identText == "myIdent"

# stringValue
var t2 = createTree()
t2.addStrLit "hello world"
var n2 = snapshot(t2)
assert n2.stringValue == "hello world"

# intValue
var t3 = createTree()
t3.addIntLit 42
var n3 = snapshot(t3)
assert n3.intValue == 42

echo "C20: PASS"
