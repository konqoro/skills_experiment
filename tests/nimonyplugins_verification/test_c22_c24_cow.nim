# Test C22, C24: NifBuilder copy-on-write - mutations detach
import std/[syncio, assertions]
import plugins

var t1 = createTree()
t1.addIdent "original"

var t2 = t1  # copy shares payload
t2.addIdent "mutated"

# t1 should NOT see the mutation (COW detaches)
assert not t1.isEmpty
assert not t2.isEmpty
# Both should have content but different
assert renderTree(t1) != renderTree(t2)

echo "C22_C24: PASS"
