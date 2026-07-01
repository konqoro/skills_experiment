import std/[assertions, os, osproc, strutils]

proc main() =
  let tmpdir = getTempDir()
  let childFile = tmpdir / "TestC20_child.nim"
  writeFile(childFile, """
proc main() =
  var p = alloc(64)
  var arr = cast[ptr int](p)
  arr[] = 42
  echo arr[]
  dealloc(p)
main()
""")

  block C20_orc:
    let (compOut, compExit) = execCmdEx("nim c -r -d:useMalloc --mm:orc -o:" & tmpdir / "test_c20_orc" & " " & childFile & " 2>&1")
    doAssert compExit == 0, compOut
    doAssert compOut.contains("42"), compOut
    echo "C20_orc: PASS"

  block C20_arc:
    let (compOut, compExit) = execCmdEx("nim c -r -d:useMalloc --mm:arc -o:" & tmpdir / "test_c20_arc" & " " & childFile & " 2>&1")
    doAssert compExit == 0, compOut
    doAssert compOut.contains("42"), compOut
    echo "C20_arc: PASS"

main()
