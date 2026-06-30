# Verify that loading a type plugin's second input does not reset genSym.
import std / [assertions, os, osproc, strutils, syncio]

let base = getTempDir() / "nimonyplugins_gensym_multiple_inputs"
if dirExists(base):
  removeDir(base)
createDir(base)

writeFile(base / "tracked.nim", """
type
  Tracked* {.plugin: "typeplug".} = object
    value*: int
""")

writeFile(base / "typeplug.nim", """
import std / assertions
import plugins

proc copyModule(root: NifCursor): NifBuilder =
  result = createTree()
  result.addSubtree root

let moduleRoot = loadPluginInput()
let beforeTypes = genSym()
discard loadTypeDefinitions()
let afterTypes = genSym()
assert beforeTypes != afterTypes

saveTree copyModule(moduleRoot)
""")

writeFile(base / "app.nim", """
import std / [assertions, syncio]
import tracked

let item = Tracked(value: 42)
assert item.value == 42
echo "C77: PASS"
""")

let command = "cd " & base.quoteShell & " && nimony c -r " &
  ("--nimcache:" & base / "nimcache").quoteShell & " app.nim"
let (output, exitCode) = execCmdEx(command)
assert exitCode == 0, output
assert output.contains("C77: PASS"), output
echo "C77: PASS"
