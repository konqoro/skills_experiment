import std/[assertions, os, osproc, strutils]

proc main() =
  let tmpdir = getTempDir()
  let childFile = tmpdir / "TestC17_child.nim"
  writeFile(childFile, "echo \"ok\"")
  let executed = execCmdEx("nim c -r " & childFile.quoteShell)
  doAssert executed.exitCode == 0, executed.output
  doAssert executed.output.contains("mm: orc"), executed.output
  echo "C17: PASS"

main()
