# Test C45: Validation scope - createTree(kind, children) validates structure;
# manual withTree does NOT validate.
import std/[syncio, assertions]
import plugins

# Manual withTree with no callee → NOT validated, stays as-is
var manual = createTree()
manual.withTree(CallX, NoLineInfo):
  discard
var manualNode = snapshot(manual)
assert $manualNode.exprKind == $CallX

echo "C45: PASS"
