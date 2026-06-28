# C68: end-to-end for-loop plugin input helpers.
import std/[os, osproc, strutils]

let base = getTempDir() / "nimonyplugins_for_loop"
if dirExists(base):
  removeDir(base)
createDir(base)

writeFile(base / "loopapi.nim", """
iterator once*(): int {.plugin: "loopplug".}
""")

writeFile(base / "loopplug.nim", """
import plugins
import std/syncio

let root = loadPluginInput()
if pluginName(root) != "once":
  saveTree errorTree("unexpected iterator plugin", root)
elif forLoopCallArgs(root).otherKind != CallargsU:
  saveTree errorTree("expected call arguments", root)
elif forLoopVars(root).otherKind notin {UnpackflatU, UnpacktupU}:
  saveTree errorTree("expected loop variables", root)
elif forLoopBody(root).stmtKind != StmtsS:
  saveTree errorTree("expected typed loop body", root)
else:
  var output = createTree()
  output.withTree StmtsS, root.info:
    output.withTree CallS, root.info:
      output.bindSym "echo"
      output.addStrLit "loop plugin ran"
  saveTree move output
""")

writeFile(base / "app.nim", """
import std/[assertions, syncio]
import loopapi
for ignored in once():
  discard
echo "C68_FOR_LOOP_PLUGIN: PASS"
""")

let result = execCmdEx("nimony c -r " & quoteShell(base / "app.nim"))
doAssert result.exitCode == 0, result.output
doAssert result.output.contains("loop plugin ran"), result.output
doAssert result.output.contains("C68_FOR_LOOP_PLUGIN: PASS"), result.output
echo "C68_FOR_LOOP_PLUGIN: PASS"
