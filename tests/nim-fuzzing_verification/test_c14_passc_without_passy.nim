import std/[os, osproc]

proc main() =
  let tmpdir = getTempDir()
  let harness = tmpdir / "TestC14_passc_only.nim"
  writeFile(harness, """
proc initialize(): cint {.cdecl, exportc: "LLVMFuzzerInitialize".} =
  {.emit: "N_CDECL(void, NimMain)(void); NimMain();".}

proc testOneInput(data: ptr UncheckedArray[byte], len: int): cint {.
    cdecl, exportc: "LLVMFuzzerTestOneInput", raises: [].} =
  result = 0
""")

  block C14:
    let (_, exit) = execCmdEx(
      "nim c --cc:clang --noMain:on -d:useMalloc -d:noSignalHandler " &
      "--passC:\"-fsanitize=fuzzer\" " &
      "--hints:off " & harness & " 2>/dev/null")
    if exit != 0:
      echo "C14: PASS"
    else:
      echo "C14: FAIL: expected linker error with --passC only"

  removeFile(harness)

main()
