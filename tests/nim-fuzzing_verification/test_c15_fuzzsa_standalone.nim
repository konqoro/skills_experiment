import std/[os, osproc, strutils]

proc main() =
  let tmpdir = getTempDir()
  let harness = tmpdir / "TestC15_fuzzsa.nim"
  let inputFile = tmpdir / "TestC15_input.bin"
  writeFile(harness, """
import std/os

proc testOneInput(data: ptr UncheckedArray[byte], len: int): cint {.
    exportc: "LLVMFuzzerTestOneInput", raises: [].} =
  result = 0
  if len >= 1:
    doAssert data[0] == 72'u8

when isMainModule:
  for i in 1..paramCount():
    var buf = readFile(paramStr(i))
    discard testOneInput(cast[ptr UncheckedArray[byte]](cstring(buf)), buf.len)
  echo "OK"
""")
  writeFile(inputFile, "Hello")

  block C15:
    let buildBin = tmpdir / "TestC15_fuzzsa_bin"
    let (_, buildExit) = execCmdEx(
      "nim c --hints:off -o:" & buildBin & " " & harness & " 2>/dev/null")
    if buildExit == 0:
      let (runOut, runExit) = execCmdEx(buildBin & " " & inputFile & " 2>/dev/null")
      if runExit == 0 and runOut.contains("OK"):
        echo "C15: PASS"
      else:
        echo "C15: FAIL: standalone run failed, exit=" & $runExit
    else:
      echo "C15: FAIL: standalone build failed"

  removeFile(harness)
  removeFile(inputFile)

main()
