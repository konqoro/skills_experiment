# C67: template input is `(stmts <name> <args...>)`.
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
  var child = callArgs(root)
  if pluginName(root) != "checkShape":
    saveTree errorTree("template plugin name was not preserved", root)
  elif not child.hasMore or child.kind != IntLit or child.intValue != 42:
    saveTree errorTree("callArgs did not point at the call argument", child)
  else:
    var outp = createTree()
    outp.addStrLit("shape-ok")
    saveTree outp
""")

writeFile(appFile, """
import std/[assertions, syncio]
import shapeapi

assert checkShape(42) == "shape-ok"
echo "C67_TEMPLATE_PROTOCOL: PASS"
""")

let res = execCmdEx("nimony c -r " & appFile.quoteShell)
doAssert res.exitCode == 0, res.output
doAssert res.output.contains("C67_TEMPLATE_PROTOCOL: PASS"), res.output

echo "C67_TEMPLATE_PROTOCOL: PASS"
