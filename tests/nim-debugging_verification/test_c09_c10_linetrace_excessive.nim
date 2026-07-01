import std/[assertions, os, osproc, strutils]

proc main() =
  let tmpdir = getTempDir()

  block C09:
    let childFile = tmpdir / "TestC09_child.nim"
    writeFile(childFile, "proc inner() = raise newException(ValueError, \"err\")\nproc main() = inner()\nmain()")
    let executed = execCmdEx(
      "nim c -r -d:release --lineTrace:on " & childFile.quoteShell)
    doAssert executed.output.contains("inner"), executed.output
    echo "C09: PASS"

  block C10:
    let src = "proc inner() = raise newException(ValueError, \"err\")\nproc outer() = inner()\nproc main() = outer()\nmain()"

    let childOn = tmpdir / "TestC10_on_child.nim"
    writeFile(childOn, src)
    let (outputOn, _) = execCmdEx("nim c -r -f --excessiveStackTrace:on -d:release --stackTrace:on --lineTrace:on " & childOn & " 2>&1")
    let onHasFullPath = outputOn.contains("/TestC10_on_child.nim(")

    let childOff = tmpdir / "TestC10_off_child.nim"
    writeFile(childOff, src)
    let (outputOff, _) = execCmdEx("nim c -r -f --excessiveStackTrace:off -d:release --stackTrace:on --lineTrace:on " & childOff & " 2>&1")
    let offHasFullPath = outputOff.contains("/TestC10_off_child.nim(")

    doAssert onHasFullPath, outputOn
    doAssert not offHasFullPath, outputOff
    echo "C10: PASS"

main()
