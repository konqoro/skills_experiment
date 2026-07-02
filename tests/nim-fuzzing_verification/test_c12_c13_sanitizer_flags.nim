import std/[os, osproc]

proc main() =
  let tmpdir = getTempDir()
  let harness = tmpdir / "TestC12C13_sanitizer_flags.nim"
  writeFile(harness, """
proc initialize(): cint {.cdecl, exportc: "LLVMFuzzerInitialize".} =
  {.emit: "N_CDECL(void, NimMain)(void); NimMain();".}

proc testOneInput(data: ptr UncheckedArray[byte], len: int): cint {.
    cdecl, exportc: "LLVMFuzzerTestOneInput", raises: [].} =
  result = 0
""")

  block C12_C13:
    let (_, exit) = execCmdEx(
      "nim c --cc:clang --noMain:on -d:useMalloc -d:noSignalHandler " &
      "--passC:\"-fsanitize=fuzzer\" --passL:\"-fsanitize=fuzzer\" " &
      "--hints:off " & harness & " 2>/dev/null")
    if exit == 0:
      echo "C12: PASS"
      echo "C13: PASS"
    else:
      echo "C12: FAIL: useMalloc + noSignalHandler build failed"
      echo "C13: SKIP"

  removeFile(harness)

main()
