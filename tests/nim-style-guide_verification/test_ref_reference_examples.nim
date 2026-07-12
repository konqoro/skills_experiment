import std/[assertions, os, osproc, strutils]

let repoRoot = parentDir(parentDir(parentDir(currentSourcePath())))
let references = repoRoot / "skills" / "nim-style-guide" / "references"
let workDir = getTempDir() / "nim_style_guide_references"
let names = [
  "core_patterns"
]

if dirExists(workDir):
  removeDir(workDir)
createDir(workDir)

for name in names:
  let reference = references / (name & ".md")
  let source = workDir / (name & ".nim")
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
    (workDir / (name & "_cache")).quoteShell & " " & source.quoteShell
  let result = execCmdEx(command)
  assert result.exitCode == 0, name & ":\n" & result.output

echo "STYLE_GUIDE_REFERENCE_EXAMPLES: PASS"
