import std/[assertions, os, osproc, strutils]

const childSrc = staticRead(
  "test_c03_c04_c05_c06_c07_c08_stack_trace_modes_src/" &
  "test_c03_c04_c05_c06_c07_c08_stack_trace_child.nim")

let tmpDir = getTempDir()
let childFile = tmpDir / "stack_trace_modes_child.nim"
writeFile(childFile, childSrc)

proc run(mode: string; source = childFile): string =
  let executed = execCmdEx(
    "nim c -r " & mode & " " & source.quoteShell)
  doAssert executed.exitCode != 0, executed.output
  result = executed.output

block defaultTrace:
  let output = run("")
  doAssert output.contains("inner"), output
  doAssert output.contains("outer"), output
  echo "C03: PASS"

block releaseTrace:
  let output = run("-d:release")
  doAssert output.contains("inner"), output
  doAssert not output.contains("outer"), output
  echo "C04: PASS"

block dangerTrace:
  let output = run("-d:danger")
  doAssert output.contains("inner"), output
  doAssert not output.contains("outer"), output
  echo "C05: PASS"

let stackSource = tmpDir / "write_stack_trace_child.nim"
writeFile(stackSource,
  "proc inner() = writeStackTrace()\nproc main() = inner()\nmain()\n")

block releaseWriteStackTrace:
  let executed = execCmdEx(
    "nim c -r -d:release " & stackSource.quoteShell)
  doAssert executed.exitCode == 0, executed.output
  doAssert executed.output.contains("No stack traceback available"),
    executed.output
  echo "C06: PASS"

block dangerWriteStackTrace:
  let executed = execCmdEx(
    "nim c -r -d:danger " & stackSource.quoteShell)
  doAssert executed.exitCode == 0, executed.output
  doAssert executed.output.contains("No stack traceback available"),
    executed.output
  echo "C07: PASS"

block restoredTrace:
  let output = run("-d:release --stackTrace:on --lineTrace:on")
  doAssert output.contains("inner"), output
  doAssert output.contains("outer"), output
  echo "C08: PASS"
