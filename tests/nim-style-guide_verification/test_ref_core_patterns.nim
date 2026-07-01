import std/[assertions, os, osproc, strutils]

let repoRoot = parentDir(parentDir(parentDir(currentSourcePath())))
let reference = repoRoot / "skills" / "nim-style-guide" /
  "references" / "core_patterns.md"
let workDir = getTempDir() / "nim_style_guide_reference"
let source = workDir / "core_patterns.nim"

if dirExists(workDir):
  removeDir(workDir)
createDir(workDir)

var code: seq[string]
var inBlock = false
var blockCount = 0
for line in readFile(reference).splitLines:
  if line == "```nim":
    assert not inBlock
    inBlock = true
    inc blockCount
  elif line == "```" and inBlock:
    inBlock = false
  elif inBlock:
    code.add line

assert not inBlock
assert blockCount == 1
writeFile(source, code.join("\n") & "\n")

let command = "nim c -r --nimcache:" &
  (workDir / "nimcache").quoteShell & " " & source.quoteShell
let result = execCmdEx(command)
assert result.exitCode == 0, result.output

echo "ref_core_patterns: PASS"
