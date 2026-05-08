import std/[os, osproc]

proc main() =
  let tmpdir = getTempDir()
  let harness = tmpdir / "TestC19_coverage.nim"
  writeFile(harness, """
proc testOneInput(data: ptr UncheckedArray[byte], len: int): cint {.
    exportc: "LLVMFuzzerTestOneInput", raises: [].} =
  result = 0
  if len > 0:
    var x = 0
    for i in 0..<len:
      x += int(data[i])
    doAssert x >= 0

proc initialize(): cint {.exportc: "LLVMFuzzerInitialize".} =
  {.emit: "N_CDECL(void, NimMain)(void); NimMain();".}
""")

  block C19:
    let buildBin = tmpdir / "TestC19_coverage_bin"
    let profraw = tmpdir / "TestC19_coverage.profraw"
    let profdata = tmpdir / "TestC19_coverage.profdata"

    let (_, buildExit) = execCmdEx(
      "nim c --cc:clang " &
      "--passC:\"-fprofile-instr-generate -fcoverage-mapping\" " &
      "--passL:\"-fprofile-instr-generate -fcoverage-mapping\" " &
      "--hints:off -o:" & buildBin & " " & harness & " 2>/dev/null")
    if buildExit != 0:
      echo "C19: FAIL: coverage build failed"
    else:
      let (_, _) = execCmdEx("LLVM_PROFILE_FILE=\"" & profraw & "\" " & buildBin & " 2>/dev/null <<< ''")
      let (_, mergeExit) = execCmdEx(
        "llvm-profdata merge -sparse " & profraw & " -o " & profdata & " 2>/dev/null")
      if mergeExit == 0:
        echo "C19: PASS"
      else:
        echo "C19: FAIL: llvm-profdata merge failed"
      removeFile(profraw)
      removeFile(profdata)

  removeFile(harness)

main()
