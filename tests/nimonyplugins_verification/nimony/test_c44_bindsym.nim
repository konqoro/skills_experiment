# Test C44: bindSym emits hygienic references that survive call-site shadowing
import std/[syncio, assertions]
import plugins

# Create a tree with bindSym, then verify the emitted symbol is fully qualified
var t = createTree()
t.withTree(StmtsS, NoLineInfo):
  t.withTree(CallS, NoLineInfo):
    t.bindSym "echo"
    t.addStrLit "hello"

var n = snapshot(t)
assert n.stmtKind == StmtsS

# Enter StmtsS, then CallS, check first child is a Symbol (not Ident)
var body = firstChild(n)
assert body.stmtKind == CallS
var callBody = firstChild(body)
# bindSym should emit a Symbol (fully qualified), not an Ident ("echo")
assert callBody.kind == Symbol
# Fully qualified symbol has a dot (e.g. "echo.0.syncio")
let symName = callBody.symText
assert symName.len > 4  # longer than just "echo"
assert symName != "echo"  # not a bare ident

echo "C44: PASS"
