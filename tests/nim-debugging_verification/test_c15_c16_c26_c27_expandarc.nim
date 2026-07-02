import std/[assertions, os, osproc, strutils]

let here = parentDir(currentSourcePath())
let child = here /
  "test_c15_c16_c26_c27_expandarc_src/test_c15_c16_c26_c27_expandarc_child.nim"

proc expand(target: string; mm = ""): string =
  var command = "nim c -r --expandArc:" & target
  if mm.len > 0:
    command.add " --mm:" & mm
  command.add " --nimcache:" &
    (getTempDir() / "nim_debugging_expand_arc_cache").quoteShell
  command.add " -o:" &
    (getTempDir() / "nim_debugging_expand_arc").quoteShell
  command.add " " & child.quoteShell
  let executed = execCmdEx(command)
  doAssert executed.exitCode == 0, executed.output
  result = executed.output

block copyExpansion:
  let output = expand("drainByCopy")
  doAssert output.contains("=copy"), output
  doAssert output.contains("=sink"), output
  doAssert output.contains("end of expandArc"), output
  echo "C15: PASS"

block memoryManagers:
  for mm in ["orc", "arc", "atomicArc"]:
    let output = expand("drainByCopy", mm)
    doAssert output.contains("=copy"), mm & ":\n" & output
  echo "C16: PASS"

block moveExpansion:
  let output = expand("drainByMove")
  doAssert output.contains("move"), output
  doAssert not output.contains("=copy"), output
  echo "C26: PASS"

block destructionExpansion:
  let output = expand("main")
  doAssert output.contains("=destroy"), output
  echo "C27: PASS"
