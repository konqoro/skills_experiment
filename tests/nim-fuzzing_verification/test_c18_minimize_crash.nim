import std/[os, osproc, strutils]

proc main() =
  let tmpdir = getTempDir()
  let harness = tmpdir / "TestC18_mincrash.nim"
  writeFile(harness, """
proc initialize(): cint {.exportc: "LLVMFuzzerInitialize".} =
  {.emit: "N_CDECL(void, NimMain)(void); NimMain();".}

proc testOneInput(data: ptr UncheckedArray[byte], len: int): cint {.
    exportc: "LLVMFuzzerTestOneInput", raises: [].} =
  result = 0
  if len >= 4 and data[0].char == 'C' and data[1].char == 'R' and
     data[2].char == 'A' and data[3].char == 'S':
    quit(1)
""")

  block C18:
    let buildBin = tmpdir / "TestC18_mincrash_bin"
    let (_, buildExit) = execCmdEx(
      "nim c --cc:clang --noMain:on -d:useMalloc -d:noSignalHandler " &
      "--passC:\"-fsanitize=fuzzer\" --passL:\"-fsanitize=fuzzer\" " &
      "--hints:off -o:" & buildBin & " " & harness & " 2>/dev/null")
    if buildExit == 0:
      let (helpOut, _) = execCmdEx(buildBin & " -help=1 2>&1")
      if helpOut.contains("minimize_crash"):
        echo "C18: PASS"
      else:
        echo "C18: FAIL: -minimize_crash flag not found"
    else:
      echo "C18: FAIL: fuzz target build failed"

  removeFile(harness)

main()
