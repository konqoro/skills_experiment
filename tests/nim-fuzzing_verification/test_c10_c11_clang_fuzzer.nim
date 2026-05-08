import std/[os, osproc]

proc main() =
  let tmpdir = getTempDir()
  let harness = tmpdir / "TestC10C11_fuzz_target.nim"
  writeFile(harness, """
proc initialize(): cint {.exportc: "LLVMFuzzerInitialize".} =
  {.emit: "N_CDECL(void, NimMain)(void); NimMain();".}

proc testOneInput(data: ptr UncheckedArray[byte], len: int): cint {.
    exportc: "LLVMFuzzerTestOneInput", raises: [].} =
  result = 0
""")

  block C10_C11:
    let (_, exit) = execCmdEx(
      "nim c --cc:clang --noMain:on -d:noSignalHandler -d:useMalloc " &
      "--passC:\"-fsanitize=fuzzer\" --passL:\"-fsanitize=fuzzer\" " &
      "--hints:off " & harness & " 2>/dev/null")
    if exit == 0:
      echo "C10: PASS"
      echo "C11: PASS"
    else:
      echo "C10: FAIL: clang + fuzzer build failed"
      echo "C11: SKIP"

  removeFile(harness)

main()
