# Current nifcore-backed plugin API: ownership, construction, traversal, and
# template/for-loop input helpers. Compile this file with Nimony, not Nim.
import std/[assertions, syncio]
import plugins

# Builders are mutable owners, but snapshots retain the storage they observed.
var tree = createTree()
tree.addIdent "before"
let old = snapshot(tree)
tree.addIdent "after"
assert old.identText == "before"

# Enum trees use withTree; arbitrary tags use an explicit balanced pair.
var raw = createTree()
raw.openTree "custom"
raw.addStrLit "payload"
raw.closeTree()
assert snapshot(raw).tagText == "custom"

# addTree consumes a complete child builder.
var child = createTree()
child.addIntLit 7
var parent = createTree()
parent.withTree StmtsS, NoLineInfo:
  parent.addTree(move child)
var item = firstChild(snapshot(parent))
assert item.kind == IntLit and item.intValue == 7

# Template input includes the invoked name before the call arguments.
var templateInput = createTree()
templateInput.withTree StmtsS, NoLineInfo:
  templateInput.addIdent "expand"
  templateInput.addIntLit 42
let templateRoot = snapshot(templateInput)
assert pluginName(templateRoot) == "expand"
var args = callArgs(templateRoot)
assert args.kind == IntLit and args.intValue == 42

# For-loop input exposes separate call-args, variables, and body subtrees.
var loopInput = createTree()
loopInput.withTree ForcallU, NoLineInfo:
  loopInput.addIdent "unroll"
  loopInput.withTree CallargsU, NoLineInfo:
    loopInput.addIntLit 3
  loopInput.withTree UnpackflatU, NoLineInfo:
    loopInput.addIdent "x"
  loopInput.withTree StmtsS, NoLineInfo:
    loopInput.addIdent "body"
let loopRoot = snapshot(loopInput)
assert pluginName(loopRoot) == "unroll"
var loopArgs = forLoopCallArgs(loopRoot)
assert loopArgs.otherKind == CallargsU
var loopVars = forLoopVars(loopRoot)
assert loopVars.otherKind == UnpackflatU
var loopBody = forLoopBody(loopRoot)
assert loopBody.stmtKind == StmtsS

# Bounded traversal has no closing-token sentinel. balancedTokens visits only
# descendant tags and advances the supplied cursor past its root.
var scan = snapshot(loopInput)
var descendants = 0
balancedTokens scan:
  assert scan.kind == TagLit
  inc descendants
assert descendants == 3
assert not scan.hasMore

echo "C62_C63_C64_C65_C67_C68_C71_C72_C73: PASS"
