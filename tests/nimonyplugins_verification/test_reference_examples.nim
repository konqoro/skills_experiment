# Compile every Nim code block in the teaching references with Nimony.
import std / [assertions, os, osproc, strutils, syncio]

let repoRoot = parentDir(parentDir(parentDir(currentSourcePath())))
let references = repoRoot / "skills" / "nimonyplugins" / "references"
let base = getTempDir() / "nimonyplugins_reference_examples"

if dirExists(base):
  removeDir(base)
createDir(base)

proc materialize(reference, outputDir: string) =
  createDir(outputDir)
  var inNimBlock = false
  var code: seq[string] = @[]
  for line in readFile(reference).splitLines:
    if line == "```nim":
      assert not inNimBlock
      inNimBlock = true
      code = @[]
    elif line == "```" and inNimBlock:
      assert code.len > 0 and code[0].startsWith("# ")
      writeFile(outputDir / code[0][2 .. ^1], code.join("\n") & "\n")
      inNimBlock = false
    elif inNimBlock:
      code.add line
  assert not inNimBlock

proc runNimony(dir, source, label: string; run = true): (string, int) =
  let command = "cd " & dir.quoteShell & " && nimony c " &
    (if run: "-r " else: "") &
    ("--nimcache:" & dir / (label & "_cache")).quoteShell & " " &
    ("-o:" & dir / (label & "_bin")).quoteShell & " " &
    source.quoteShell
  execCmdEx(command)

block:
  let dir = base / "template"
  materialize(references / "template_plugin.md", dir)
  let result = runNimony(dir, "app.nim", "template")
  assert result[1] == 0, result[0]
  assert result[0].contains("TEMPLATE: PASS"), result[0]

block:
  let dir = base / "replacer"
  materialize(references / "replacer_api.md", dir)
  let result = runNimony(dir, "app.nim", "replacer")
  assert result[1] == 0, result[0]
  assert result[0].contains("hello"), result[0]

block:
  let dir = base / "for_loop"
  materialize(references / "for_loop_plugin.md", dir)
  let result = runNimony(dir, "app.nim", "for_loop")
  assert result[1] == 0, result[0]
  assert result[0].contains("FOR_LOOP: PASS"), result[0]

block:
  let dir = base / "module"
  materialize(references / "module_plugin.md", dir)
  let result = runNimony(dir, "app.nim", "module")
  assert result[1] == 0, result[0]
  assert result[0].contains("MODULE: PASS"), result[0]
  assert not result[0].contains("this call is removed"), result[0]

block:
  let dir = base / "type"
  materialize(references / "type_plugin.md", dir)
  let good = runNimony(dir, "app.nim", "type_good")
  assert good[1] == 0, good[0]
  assert good[0].contains("TYPE: PASS"), good[0]

  let bad = runNimony(dir, "bad.nim", "type_bad", run = false)
  assert bad[1] != 0, bad[0]
  assert bad[0].contains("StackOnly values must be local"), bad[0]

echo "REFERENCE_EXAMPLES: PASS"
