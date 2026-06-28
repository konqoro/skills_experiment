# Test C32, C35, C67: end-to-end plugin entrypoint via template {.plugin.}
# and default loadPluginInput()/saveTree() overloads.
import std/[os, osproc, strutils]

let base = getTempDir() / "nimonyplugins_e2e_plugin"
if dirExists(base):
  removeDir(base)
createDir(base)

let runtimeFile = base / "shoutdsl.nim"
let pluginFile = base / "shoutplugin.nim"
let appFile = base / "app.nim"

writeFile(runtimeFile, """
template shout*(spec: string): untyped {.plugin: "shoutplugin".}
""")

writeFile(pluginFile, """
import std/strutils
import plugins

let root = loadPluginInput()
let arg = callArgs(root)

if arg.kind == StrLit:
  var resultTree = createTree()
  resultTree.addStrLit(arg.stringValue.toUpperAscii)
  saveTree(resultTree)
else:
  saveTree errorTree("shout expects a string literal", arg)
""")

writeFile(appFile, """
import std / assertions
import std / syncio
import shoutdsl

assert shout("hello") == "HELLO"
echo "C32_C35_C67: PASS"
""")

let cmd = "nimony c -r " & appFile.quoteShell
let res = execCmdEx(cmd)
doAssert res.exitCode == 0, res.output
doAssert res.output.contains("C32_C35_C67: PASS"), res.output

echo "C32_C35_C67: PASS"
