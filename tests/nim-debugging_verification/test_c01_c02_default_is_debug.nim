import std/[assertions, os, osproc, strutils]

proc main() =
  let tmpdir = getTempDir()
  let childFile = tmpdir / "TestC01C02_child.nim"
  writeFile(childFile, "echo \"child ok\"")

  block C01:
    let (output, exitCode) = execCmdEx("nim c -r " & childFile & " 2>&1")
    doAssert exitCode == 0, output
    doAssert output.contains("DEBUG BUILD"), output
    echo "C01: PASS"

  block C02:
    let (output, exitCode) = execCmdEx("nim c -r -d:debug " & childFile & " 2>&1")
    doAssert exitCode == 0, output
    doAssert output.contains("DEBUG BUILD"), output
    echo "C02: PASS"

main()
