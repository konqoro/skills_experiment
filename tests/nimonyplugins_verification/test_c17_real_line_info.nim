# Test C17: real source line info from plugin input decodes to file path,
# 1-based line, and 1-based column.
import std/[os, osproc, strutils]

let base = getTempDir() / "nimonyplugins_real_line_info"
if dirExists(base):
  removeDir(base)
createDir(base)

let runtimeFile = base / "locdsl.nim"
let pluginFile = base / "locplugin.nim"
let appFile = base / "app.nim"

writeFile(runtimeFile, """
template sourceLoc*(x: untyped): string {.plugin: "locplugin".}
""")

writeFile(pluginFile, """
import plugins
import std/strutils

proc firstArg(root: NifCursor): NifCursor =
  result = callArgs(root)

let arg = firstArg(loadPluginInput())
let info = arg.info
if not plugins.isValid(info):
  saveTree errorTree("expected real line info on template argument", arg)
else:
  let pos = lineCol(info)
  let path = filePath(info)
  if not path.endsWith("app.nim") or pos.line <= 0 or pos.col <= 0:
    saveTree errorTree("expected non-empty file path and positive line/col", arg)
  else:
    var resultTree = createTree()
    resultTree.addStrLit("real-line-info-ok")
    saveTree move resultTree
""")

writeFile(appFile, """
import std/[assertions, syncio]
import locdsl

let got = sourceLoc(12345)
assert got == "real-line-info-ok"
echo "C17_REAL_LINE_INFO: PASS"
""")

let res = execCmdEx("nimony c -r " & appFile.quoteShell)
doAssert res.exitCode == 0, res.output
doAssert res.output.contains("C17_REAL_LINE_INFO: PASS"), res.output

echo "C17_REAL_LINE_INFO: PASS"
