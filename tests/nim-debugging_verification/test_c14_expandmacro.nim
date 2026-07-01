import std/[assertions, os, osproc, strutils]

let here = parentDir(currentSourcePath())
let child = here / "test_c14_expandmacro_src/test_c14_expandmacro_child.nim"
let result = execCmdEx(
  "nim c --expandMacro:simpleLog " & child.quoteShell)

doAssert result.exitCode == 0, result.output
doAssert result.output.contains("[ExpandMacro]"), result.output
doAssert result.output.contains("echo"), result.output

echo "C14: PASS"
