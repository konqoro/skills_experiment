# Test C50, C51, C56, C57: Replacer API — keep, drop, replace, keepTag,
# loopKeepTag, peek, getCursor, setCursor, replaceHead, loadReplacer, saveReplacer
import std/[syncio, assertions, os]
import plugins

let tmpDir = getTempDir()

# ── C51: loadReplacer / saveReplacer round-trip ──────────────────────
var inputTree = createTree()
inputTree.withTree(StmtsS, NoLineInfo):
  inputTree.addIdent "a"
  inputTree.withTree(CallX, NoLineInfo):
    inputTree.addIdent "echo"
    inputTree.addStrLit "hello"
  inputTree.addIdent "b"
  inputTree.withTree(CallX, NoLineInfo):
    inputTree.addIdent "record"

let inFile = tmpDir / "replacer_in.nif"
saveTree(inputTree, inFile)

# ── C50: keep, drop, keepTag, loopKeepTag ────────────────────────────
var r = loadReplacer(inFile)
loopKeepTag r:
  keep r, Any               # "a"
  drop r, Any               # skip CallX("echo", "hello")
  keep r, Any               # "b"
  keepTag r:                # descend into CallX("record")
    keep r, Any             # "record"

# Verify output
var n1 = snapshot(r.dest)
assert n1.stmtKind == StmtsS
var c1 = firstChild(n1)
assert c1.identText == "a"
skip c1
assert c1.identText == "b"
skip c1
assert c1.exprKind == CallX
var ic1 = firstChild(c1)
assert ic1.identText == "record"

# ── C57: replaceHead ─────────────────────────────────────────────────
var input2 = createTree()
input2.withTree(CallX, NoLineInfo):
  input2.addIdent "oldfn"
  input2.addStrLit "arg"

let rhFile = tmpDir / "replacer_rh.nif"
saveTree(input2, rhFile)
var r2 = loadReplacer(rhFile)
replaceHead r2, CallS, NoLineInfo:
  keep r2, Any
  keep r2, Any

var n2 = snapshot(r2.dest)
assert n2.stmtKind == CallS

# ── C56: peek / getCursor / setCursor ────────────────────────────────
var input3 = createTree()
input3.withTree(StmtsS, NoLineInfo):
  input3.addIdent "x"
  input3.addIdent "y"
  input3.addIdent "z"

let pkFile = tmpDir / "replacer_peek.nif"
saveTree(input3, pkFile)
var r3 = loadReplacer(pkFile)

loopKeepTag r3:
  let saved = getCursor(r3)
  keep r3, Any             # "x"
  keep r3, Any             # "y"
  setCursor(r3, saved)     # rewind
  # peek: read-ahead without consuming
  var foundY = false
  peek r3:
    var probe = getCursor(r3)
    skip probe
    if probe.identText == "y":
      foundY = true
  assert foundY
  keep r3, Any             # "x"
  keep r3, Any             # "y"
  keep r3, Any             # "z"

# ── C51: saveReplacer round-trip ─────────────────────────────────────
let outFile = tmpDir / "replacer_out.nif"
saveReplacer(r, outFile)
var reloaded = loadReplacer(outFile)
loopKeepTag reloaded:
  keep reloaded, Any
  keep reloaded, Any
  keepTag reloaded:
    keep reloaded, Any
var rn = snapshot(reloaded.dest)
assert rn.stmtKind == StmtsS
var rc = firstChild(rn)
assert rc.identText == "a"
skip rc
assert rc.identText == "b"
skip rc
assert rc.exprKind == CallX

echo "C50_C51_C56_C57: PASS"
