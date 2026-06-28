# Test C50, C51, C56, C57: Replacer API — keep, drop, replace, keepTag,
# loopKeepTag, peek, getCursor, setCursor, replaceHead, loadReplacer, saveReplacer
import std/[syncio, assertions, os]
import plugins

let tmpDir = getTempDir()

# ── C51: loadReplacer / saveReplacer round-trip ──────────────────────
proc createMainInput(): NifBuilder =
  result = createTree()
  result.withTree(StmtsS, NoLineInfo):
    result.addIdent "a"
    result.withTree(CallX, NoLineInfo):
      result.addIdent "echo"
      result.addStrLit "hello"
    result.addIdent "b"
    result.withTree(CallX, NoLineInfo):
      result.addIdent "record"

let inFile = tmpDir / "replacer_in.nif"
saveTree(createMainInput(), inFile)

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
proc createReplaceHeadInput(): NifBuilder =
  result = createTree()
  result.withTree(CallX, NoLineInfo):
    result.addIdent "oldfn"
    result.addStrLit "arg"

let rhFile = tmpDir / "replacer_rh.nif"
saveTree(createReplaceHeadInput(), rhFile)
var r2 = loadReplacer(rhFile)
replaceHead r2, CallS, NoLineInfo:
  keep r2, Any
  keep r2, Any

var n2 = snapshot(r2.dest)
assert n2.stmtKind == CallS

# ── C56: peek / getCursor / setCursor ────────────────────────────────
proc createPeekInput(): NifBuilder =
  result = createTree()
  result.withTree(StmtsS, NoLineInfo):
    result.addIdent "x"
    result.addIdent "y"
    result.addIdent "z"

let pkFile = tmpDir / "replacer_peek.nif"
saveTree(createPeekInput(), pkFile)
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
