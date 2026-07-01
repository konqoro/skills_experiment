# Test C49: balancedTokens deep-scans all compound nodes in a subtree
import std/[syncio, assertions]
import plugins

var t = createTree()
t.withTree(StmtsS, NoLineInfo):
  t.withTree(CallX, NoLineInfo):
    t.addIdent "f1"
  t.addIdent "atom"
  t.withTree(IfS, NoLineInfo):
    t.withTree(TrueX, NoLineInfo):
      discard
    t.withTree(CallX, NoLineInfo):
      t.addIdent "f2"

var n = snapshot(t)

# balancedTokens visits every TagLit inside the subtree (not the root itself)
var parLeCount = 0
balancedTokens n:
  parLeCount += 1

# CallX(f1), IfS, TrueX, CallX(f2) = 4 (root StmtsS not included)
assert parLeCount == 4

echo "C49: PASS"
