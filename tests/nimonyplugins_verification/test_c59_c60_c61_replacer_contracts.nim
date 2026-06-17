# Test C59, C60, C61: Replacer misuse contracts.
import std/[os, osproc, strutils]

let base = getTempDir() / "nimonyplugins_replacer_contracts"
if dirExists(base):
  removeDir(base)
createDir(base)

let pluginDir = parentDir(currentSourcePath())

proc runChild(name, source: string): (string, int) =
  let path = base / name
  writeFile(path, source)
  let cmd = "cd " & quoteShell(base) & " && nimony c -r " &
      quoteShell("--path:" & pluginDir) & " " & quoteShell(path)
  execCmdEx(cmd)

let wrongLevel = runChild("wrong_level.nim", """
import plugins

var input = createTree()
input.withTree(StmtsS, NoLineInfo):
  input.addIntLit 42
let inFile = "wrong_level_input.nif"
saveTree(input, inFile)

var r = loadReplacer(inFile)
keep r, Expr
""")
doAssert wrongLevel[1] != 0, wrongLevel[0]
doAssert wrongLevel[0].contains("expected Expr"), wrongLevel[0]

let unconsumed = runChild("unconsumed_keep_tag.nim", """
import plugins

var input = createTree()
input.withTree(StmtsS, NoLineInfo):
  input.addIdent "a"
  input.addIdent "b"
let inFile = "unconsumed_keep_tag_input.nif"
saveTree(input, inFile)

var r = loadReplacer(inFile)
keepTag r:
  keep r, Any
""")
doAssert unconsumed[1] != 0, unconsumed[0]
doAssert unconsumed[0].contains("body must consume all children"), unconsumed[0]

let peekDest = runChild("peek_dest_persists.nim", """
import std/[assertions, strutils, syncio]
import plugins

var input = createTree()
input.withTree(StmtsS, NoLineInfo):
  input.addIntLit 42
let inFile = "peek_dest_input.nif"
saveTree(input, inFile)

var r = loadReplacer(inFile)
keepTag r:
  peek r:
    r.dest.addIntLit 99
  keep r, Expr

let rendered = renderTree(r.dest)
assert rendered.contains("99")
assert rendered.contains("42")
echo "PEEK_DEST: PASS"
""")
doAssert peekDest[1] == 0, peekDest[0]
doAssert peekDest[0].contains("PEEK_DEST: PASS"), peekDest[0]

echo "C59_C60_C61: PASS"
