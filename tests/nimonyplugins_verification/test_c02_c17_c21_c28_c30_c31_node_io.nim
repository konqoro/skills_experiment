# Test C02, C17, C21, C30, C31:
# NifCursor copy semantics and lifetime, line-info helpers, raw tag inspection,
# and explicit load/save round-trip.
import std/[syncio, assertions, os]
import plugins

proc makeNode(): NifCursor =
  var t = createTree()
  t.withTree(StmtsS, NoLineInfo):
    t.addIdent "kept"
    t.addIdent "alive"
  result = snapshot(t)

proc main() =
  # C02, C31: copied NifCursors are independent read handles and keep the snapshot alive.
  var n = makeNode()
  assert n.stmtKind == StmtsS
  var probe = n
  var body = firstChild(probe)
  assert body.identText == "kept"
  assert n.stmtKind == StmtsS
  let rn = renderNode(n)
  assert rn.len > 0

  # C17: invalid line info reports no source location.
  let valid = plugins.isValid(NoLineInfo)
  assert not valid
  assert filePath(NoLineInfo) == ""
  let pos = lineCol(NoLineInfo)
  assert pos.line == 0
  assert pos.col == 0

  # C21: IDs are pool-local handles; text lookup goes through the cursor pool.
  assert n.tagText == "stmts"
  assert tagText(n.tagId) == "stmts"

  # C30: explicit save/load round-trip through a real .nif file.
  var t = createTree()
  t.withTree(CallX, NoLineInfo):
    t.addIdent "echo"
    t.addStrLit "hello"
  let tmpFile = getTempDir() / "nimonyplugins_roundtrip.nif"
  saveTree(move t, tmpFile)

  let loaded = loadPluginInput(tmpFile)
  assert loaded.exprKind == CallX
  let rl = renderNode(loaded)
  assert rl.len > 0

  echo "C02_C17_C21_C30_C31: PASS"

main()
