# Test C78: The compiler validates argument count against the template
# signature at the call site before a template plugin is ever invoked.
import std/[os, osproc, strutils]

let base = getTempDir() / "nimonyplugins_template_arity"
if dirExists(base):
  removeDir(base)
createDir(base)

writeFile(base / "greetplug.nim", """
import plugins
proc tr(n: NifCursor): NifBuilder =
  result = createTree()
  result.addStrLit "hi"
var i = loadPluginInput()
saveTree tr(i)
""")

writeFile(base / "greet.nim", """
template greet*(name: string): string {.plugin: "greetplug".}
""")

writeFile(base / "toomany.nim", """
import std/syncio
import greet
echo greet("a", "b")
""")

writeFile(base / "toofew.nim", """
import std/syncio
import greet
echo greet()
""")

let tooMany = execCmdEx("nimony c " & (base / "toomany.nim").quoteShell)
doAssert tooMany.exitCode != 0, "compiler accepted a too-many-arguments call"
doAssert "too many arguments" in tooMany.output, tooMany.output

let tooFew = execCmdEx("nimony c " & (base / "toofew.nim").quoteShell)
doAssert tooFew.exitCode != 0, "compiler accepted a too-few-arguments call"
doAssert "too few arguments" in tooFew.output, tooFew.output

echo "C78: PASS"
