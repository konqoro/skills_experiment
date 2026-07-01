import std/[os, osproc, strutils]

let tmpDir = getTempDir()
let cleanSource = tmpDir / "test_c22_clean.nim"
let leakSource = tmpDir / "test_c22_leak.nim"
let cleanBinary = tmpDir / "test_c22_clean"
let leakBinary = tmpDir / "test_c22_leak"

writeFile(cleanSource, """
proc cMalloc(size: csize_t): pointer
    {.importc: "malloc", header: "<stdlib.h>".}
proc cFree(p: pointer)
    {.importc: "free", header: "<stdlib.h>".}

let p = cMalloc(64)
cast[ptr int](p)[] = 42
cFree(p)
""")

writeFile(leakSource, """
proc cMalloc(size: csize_t): pointer
    {.importc: "malloc", header: "<stdlib.h>".}

proc leak() =
  let p = cMalloc(64)
  cast[ptr int](p)[] = 42

leak()
""")

proc compile(source, output: string) =
  let result = execCmdEx(
    "nim c -g -o:" & output.quoteShell & " " & source.quoteShell)
  doAssert result.exitCode == 0, result.output

proc valgrind(binary: string): tuple[output: string, exitCode: int] =
  execCmdEx("valgrind --leak-check=full --error-exitcode=1 " &
    binary.quoteShell)

compile(cleanSource, cleanBinary)
let clean = valgrind(cleanBinary)
doAssert clean.exitCode == 0, clean.output
doAssert clean.output.contains("ERROR SUMMARY: 0 errors")

compile(leakSource, leakBinary)
let leak = valgrind(leakBinary)
doAssert leak.exitCode != 0
doAssert leak.output.contains("definitely lost: 64 bytes")

echo "C22: PASS"
