# Test C37: a template plugin receives call-site arguments wrapped in StmtsS.
import std/[os, osproc, strutils]

let base = getTempDir() / "nimonyplugins_template_root_shape"
if dirExists(base):
  removeDir(base)
createDir(base)

let runtimeFile = base / "shapeapi.nim"
let pluginFile = base / "shapeplugin.nim"
let appFile = base / "app.nim"

writeFile(runtimeFile, """
template checkShape*(x: untyped): string {.plugin: "shapeplugin".}
""")

writeFile(pluginFile, """
import plugins

let root = loadPluginInput()
if root.stmtKind != StmtsS:
  saveTree errorTree("template plugin input root was not StmtsS", root)
else:
  var child = firstChild(root)
  if not child.hasMore or child.kind != IntLit or child.intValue != 42:
    saveTree errorTree("template plugin first child was not the call argument", child)
  else:
    var outp = createTree()
    outp.addStrLit("shape-ok")
    saveTree outp
""")

writeFile(appFile, """
import std/[assertions, syncio]
import shapeapi

assert checkShape(42) == "shape-ok"
echo "C37_TEMPLATE_ROOT_SHAPE: PASS"
""")

let res = execCmdEx("nimony c -r " & appFile.quoteShell)
doAssert res.exitCode == 0, res.output
doAssert res.output.contains("C37_TEMPLATE_ROOT_SHAPE: PASS"), res.output

echo "C37_TEMPLATE_ROOT_SHAPE: PASS"
