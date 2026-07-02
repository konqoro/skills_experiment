import std/[os, osproc]

proc main() =
  let tmpdir = getTempDir()
  let harness = tmpdir / "TestC19_coverage.nim"
  writeFile(harness, """
proc testOneInput(data: ptr UncheckedArray[byte], len: int): cint {.
    cdecl, exportc: "LLVMFuzzerTestOneInput", raises: [].} =
  result = 0
  if len > 0:
    var x = 0
    for i in 0..<len:
      x += int(data[i])
    doAssert x >= 0

proc initialize(): cint {.cdecl, exportc: "LLVMFuzzerInitialize".} =
  {.emit: "N_CDECL(void, NimMain)(void); NimMain();".}
""")

  block C19:
    let buildBin = tmpdir / "TestC19_coverage_bin"
    let profraw = tmpdir / "TestC19_coverage.profraw"
    let profdata = tmpdir / "TestC19_coverage.profdata"

    let (_, buildExit) = execCmdEx(
      "nim c --cc:clang --panics:on --noMain:on " &
      "-d:noSignalHandler -d:useMalloc " &
      "--passC:\"-fsanitize=fuzzer -fprofile-instr-generate -fcoverage-mapping\" " &
      "--passL:\"-fsanitize=fuzzer -fprofile-instr-generate -fcoverage-mapping\" " &
      "--hints:off -o:" & buildBin & " " & harness & " 2>/dev/null")
    if buildExit != 0:
      echo "C19: FAIL: coverage build failed"
    else:
      let (_, runExit) = execCmdEx(
        "LLVM_PROFILE_FILE=\"" & profraw & "\" ASAN_OPTIONS=detect_leaks=0 " &
        buildBin & " -runs=10 2>/dev/null")
      if runExit == 0 and fileExists(profraw):
        echo "C19: PASS"
      else:
        echo "C19: FAIL: coverage run did not produce profraw data"
      if fileExists(profraw): removeFile(profraw)
      if fileExists(profdata): removeFile(profdata)

  removeFile(harness)

main()
