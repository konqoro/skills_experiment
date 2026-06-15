# Test C06, C32: validated createTree with kind+children
import std/[syncio, assertions]
import plugins

# Valid construction: CallX with a child
var child = createTree()
child.addIdent "foo"

var t = createTree(CallX, [child])
assert not t.isEmpty

echo "C06_C32: PASS"
