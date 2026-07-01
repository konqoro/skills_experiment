import std/[assertions, os, osproc]

proc main() =
  let tmpdir = getTempDir()
  let childFile = tmpdir / "TestC18_child.nim"
  writeFile(childFile, "echo \"ok\"")

  let (outA, exitA) = execCmdEx("nim c --debugger:native -o:" & tmpdir / "test_c18_a" & " " & childFile & " 2>&1")
  let (outB, exitB) = execCmdEx("nim c --debuginfo --linedir:on -o:" & tmpdir / "test_c18_b" & " " & childFile & " 2>&1")

  doAssert exitA == 0, outA
  doAssert exitB == 0, outB
  echo "C18: PASS"

main()
