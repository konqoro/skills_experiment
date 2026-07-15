import std/[assertions, os, osproc, strutils, syncio]

let base = getTempDir() / "nimonyplugins_constructed_tree_shape"
if dirExists(base):
  removeDir(base)
createDir(base)

writeFile(base / "shapeapi.nim", """
template validCall*(): untyped {.plugin: "shapeplugin".}
template invalidCall*(): untyped {.plugin: "shapeplugin".}
""")

writeFile(base / "shapeplugin.nim", """
import plugins

let input = loadPluginInput()
var output = createTree()

output.withTree CallX, NoLineInfo:
  if pluginName(input) == "validCall":
    output.addIdent "echo"
    output.addStrLit "valid shape"
  else:
    output.withTree StmtsS, NoLineInfo:
      output.addIdent "echo"

saveTree output
""")

writeFile(base / "valid_app.nim", """
import shapeapi
validCall()
""")

writeFile(base / "invalid_app.nim", """
import shapeapi
invalidCall()
""")

let valid = execCmdEx(
  "nimony c -r " & quoteShell(base / "valid_app.nim"))
doAssert valid.exitCode == 0, valid.output
doAssert valid.output.contains("valid shape"), valid.output

let invalid = execCmdEx(
  "nimony c " & quoteShell(base / "invalid_app.nim"))
doAssert invalid.exitCode != 0, invalid.output

echo "C29: PASS"
