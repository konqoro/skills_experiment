## Extracts module_layout.md and runs it against a real shared C library.

import std/[os, osproc, strutils]

const
  testDir = currentSourcePath.parentDir
  repoRoot = testDir.parentDir.parentDir
  reference = repoRoot /
    "skills/nim-c-wrappers/references/module_layout.md"
  cSource = testDir / "test_ref_module_layout_real_src/foo.c"

let workDir = getTempDir() / "nim_c_wrappers_module_layout"
let bindingsDir = workDir / "src/bindings"
let rawModule = bindingsDir / "foo_raw.nim"
let wrapperModule = workDir / "src/foo.nim"
let mainModule = workDir / "main.nim"
let library = workDir / "libfoo.so"

if dirExists(workDir):
  removeDir(workDir)
createDir(workDir)
createDir(workDir / "src")
createDir(bindingsDir)

let markdown = readFile(reference)
var nimBlocks: seq[string]
var position = 0
while true:
  let blockStart = markdown.find("```nim\n", position)
  if blockStart < 0:
    break
  let contentStart = blockStart + "```nim\n".len
  let blockEnd = markdown.find("\n```", contentStart)
  doAssert blockEnd >= 0
  nimBlocks.add markdown[contentStart..<blockEnd] & "\n"
  position = blockEnd + 4

doAssert nimBlocks.len == 2
writeFile(rawModule, nimBlocks[0])
writeFile(wrapperModule, nimBlocks[1])
writeFile(mainModule, """
import src/foo

var texture = loadTexture("test.png")
doAssert texture.id == 7
doAssert texture.width == 64
doAssert texture.height == 32

let source = Rect(x: 0, y: 0, width: 64, height: 32)
let dest = Rect(x: 10, y: 20, width: 64, height: 32)
let color = Color(r: 255, g: 255, b: 255, a: 255)
drawTexture(texture, source, dest, color)
""")

let buildLibrary = execCmdEx(
  "cc -shared -fPIC -o " & library.quoteShell & " " &
  cSource.quoteShell)
doAssert buildLibrary.exitCode == 0, buildLibrary.output

let command =
  "LD_LIBRARY_PATH=" & workDir.quoteShell &
  " nim c -r --nimcache:" & (workDir / "nimcache").quoteShell &
  " --out:" & (workDir / "main").quoteShell & " " &
  mainModule.quoteShell
let run = execCmdEx(command)
doAssert run.exitCode == 0, run.output

echo "ref_module_layout_real: PASS"
