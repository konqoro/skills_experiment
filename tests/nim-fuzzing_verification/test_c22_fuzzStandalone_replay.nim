import std/[os, osproc, strutils]

proc main() =
  let tmpdir = getTempDir()

  block C22_fuzzStandalone_compiles_and_replays:
    let harness = tmpdir / "TestC22_harness.nim"
    let inputFile = tmpdir / "TestC22_input.bin"

    writeFile(harness, """
proc testOneInput(data: ptr UncheckedArray[byte], len: int): cint {.
    exportc: "LLVMFuzzerTestOneInput", raises: [].} =
  result = 0
  if len >= 1:
    doAssert data[0] == 72'u8

proc initialize(): cint {.exportc: "LLVMFuzzerInitialize".} =
  {.emit: "N_CDECL(void, NimMain)(void); NimMain();".}

when defined(fuzzStandalone):
  import std/[cmdline, syncio]
  stderr.write "StandaloneFuzzTarget: running " & $paramCount() & " inputs\\n"
  for i in 1..paramCount():
    var buf = readFile(paramStr(i))
    discard testOneInput(cast[ptr UncheckedArray[byte]](cstring(buf)), buf.len)
""")
    writeFile(inputFile, "Hello")

    let buildBin = tmpdir / "TestC22_bin"
    let (_, buildExit) = execCmdEx(
      "nim c --hints:off -d:fuzzStandalone -o:" & buildBin & " " &
      harness & " 2>&1")
    if buildExit == 0:
      let (runOut, runExit) = execCmdEx(buildBin & " " & inputFile & " 2>&1")
      if runExit == 0:
        echo "C22: PASS"
      else:
        echo "C22: FAIL: standalone replay exited non-zero, exit=" & $runExit &
             " output=" & runOut.strip
    else:
      echo "C22: FAIL: build with -d:fuzzStandalone failed"

    for f in [harness, inputFile, buildBin]:
      if fileExists(f): removeFile(f)

  block C23_fuzzStandalone_rejects_bad_input:
    let harness = tmpdir / "TestC23_harness.nim"
    let inputFile = tmpdir / "TestC23_bad_input.bin"

    writeFile(harness, """
proc testOneInput(data: ptr UncheckedArray[byte], len: int): cint {.
    exportc: "LLVMFuzzerTestOneInput", raises: [].} =
  result = 0
  if len >= 1:
    doAssert data[0] == 72'u8

proc initialize(): cint {.exportc: "LLVMFuzzerInitialize".} =
  {.emit: "N_CDECL(void, NimMain)(void); NimMain();".}

when defined(fuzzStandalone):
  import std/[cmdline, syncio]
  stderr.write "StandaloneFuzzTarget: running " & $paramCount() & " inputs\\n"
  for i in 1..paramCount():
    var buf = readFile(paramStr(i))
    discard testOneInput(cast[ptr UncheckedArray[byte]](cstring(buf)), buf.len)
""")
    writeFile(inputFile, "Xello")

    let buildBin = tmpdir / "TestC23_bin"
    let (_, buildExit) = execCmdEx(
      "nim c --hints:off -d:fuzzStandalone -o:" & buildBin & " " &
      harness & " 2>&1")
    if buildExit == 0:
      let (runOut, runExit) = execCmdEx(buildBin & " " & inputFile & " 2>&1")
      if runExit != 0:
        echo "C23: PASS"
      else:
        echo "C23: FAIL: bad input should have crashed but exited 0"
    else:
      echo "C23: FAIL: build with -d:fuzzStandalone failed"

    for f in [harness, inputFile, buildBin]:
      if fileExists(f): removeFile(f)

  block C24_fuzzStandalone_no_define_normal_build:
    let harness = tmpdir / "TestC24_harness.nim"

    writeFile(harness, """
proc testOneInput(data: ptr UncheckedArray[byte], len: int): cint {.
    exportc: "LLVMFuzzerTestOneInput", raises: [].} =
  result = 0

proc initialize(): cint {.exportc: "LLVMFuzzerInitialize".} =
  {.emit: "N_CDECL(void, NimMain)(void); NimMain();".}

when defined(fuzzStandalone):
  import std/[cmdline, syncio]
  stderr.write "StandaloneFuzzTarget: running " & $paramCount() & " inputs\\n"
  for i in 1..paramCount():
    var buf = readFile(paramStr(i))
    discard testOneInput(cast[ptr UncheckedArray[byte]](cstring(buf)), buf.len)

echo "NO_DEFINE_OK"
""")

    let buildBin = tmpdir / "TestC24_bin"
    let (_, buildExit) = execCmdEx(
      "nim c --hints:off -o:" & buildBin & " " & harness & " 2>&1")
    if buildExit == 0:
      let (runOut, runExit) = execCmdEx(buildBin & " 2>&1")
      if runExit == 0 and runOut.contains("NO_DEFINE_OK"):
        echo "C24: PASS"
      else:
        echo "C24: FAIL: run without -d:fuzzStandalone failed, exit=" & $runExit
    else:
      echo "C24: FAIL: build without -d:fuzzStandalone failed"

    for f in [harness, buildBin]:
      if fileExists(f): removeFile(f)

main()
