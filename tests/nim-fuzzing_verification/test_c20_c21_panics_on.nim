import std/[os, osproc, strutils]

proc main() =
  let tmpdir = getTempDir()

  block panics_on_builds:
    # C20: --panics:on makes Defect subtypes crash the process immediately
    # Confirm it builds and links with fuzzer flags
    let harness = tmpdir / "TestC20_panics.nim"
    writeFile(harness, """
proc testOneInput(data: ptr UncheckedArray[byte], len: int): cint {.
    exportc: "LLVMFuzzerTestOneInput", raises: [].} =
  result = 0

proc initialize(): cint {.exportc: "LLVMFuzzerInitialize".} =
  {.emit: "N_CDECL(void, NimMain)(void); NimMain();".}
""")

    let (_, buildExit) = execCmdEx(
      "nim c --cc:clang --panics:on --noMain:on -d:useMalloc -d:noSignalHandler " &
      "--passC:\"-fsanitize=fuzzer\" --passL:\"-fsanitize=fuzzer\" " &
      "--hints:off " & harness & " 2>/dev/null")
    if buildExit == 0:
      echo "C20: PASS"
    else:
      echo "C20: FAIL: --panics:on + fuzzer build failed"
    removeFile(harness)

  block panics_on_crashes_on_defect:
    # C21: With --panics:on, a Defect inside testOneInput kills the process
    # without needing explicit except Defect: quit(70)
    let harness = tmpdir / "TestC21_panics_crash.nim"
    writeFile(harness, """
proc testOneInput(data: ptr UncheckedArray[byte], len: int): cint {.
    exportc: "LLVMFuzzerTestOneInput", raises: [].} =
  var arr = @[1, 2, 3]
  discard arr[999]  # guaranteed IndexDefect
  result = 0

when isMainModule:
  var buf: array[4, byte]
  try:
    discard testOneInput(cast[ptr UncheckedArray[byte]](addr buf[0]), 4)
  except:
    echo "UNEXPECTED: Defect was caught"
  echo "UNEXPECTED: survived"
""")

    let buildBin = tmpdir / "TestC21_panics_crash_bin"
    let (_, buildExit) = execCmdEx(
      "nim c --panics:on --hints:off -o:" & buildBin & " " & harness & " 2>/dev/null")
    if buildExit != 0:
      echo "C21: FAIL: build failed"
    else:
      let (runOut, runExit) = execCmdEx(buildBin & " 2>/dev/null")
      if runExit != 0 and not runOut.contains("UNEXPECTED") and not runOut.contains("survived"):
        echo "C21: PASS"
      else:
        echo "C21: FAIL: Defect did not crash process, exit=" & $runExit
    removeFile(harness)

main()
