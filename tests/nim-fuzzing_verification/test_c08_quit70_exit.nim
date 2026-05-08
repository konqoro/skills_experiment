import std/[os, osproc]

proc main() =
  let tmpdir = getTempDir()

  block C08:
    let quit70 = tmpdir / "TestC08_quit70.nim"
    writeFile(quit70, "quit(70)")
    let (_, exit70) = execCmdEx("nim c -r --hints:off " & quit70 & " 2>/dev/null")
    if exit70 != 0:
      echo "C08: PASS"
    else:
      echo "C08: FAIL: quit(70) should produce non-zero exit"
    removeFile(quit70)

main()
