import std/[os, osproc, strutils]

proc main() =
  let tmpdir = getTempDir()

  block ref_simple_harness_compiles:
    let harness = tmpdir / "ref_simple_harness.nim"
    writeFile(harness, """
proc fuzzMe(data: openarray[byte]): bool =
  result = data.len >= 3 and
    data[0].char == 'F' and
    data[1].char == 'U' and
    data[2].char == 'Z' and
    data[3].char == 'Z'

proc initialize(): cint {.exportc: "LLVMFuzzerInitialize".} =
  {.emit: "N_CDECL(void, NimMain)(void); NimMain();".}

proc testOneInput(data: ptr UncheckedArray[byte], len: int): cint {.
    exportc: "LLVMFuzzerTestOneInput", raises: [].} =
  result = 0
  discard fuzzMe(data.toOpenArray(0, len-1))
""")
    let (_, exitCode) = execCmdEx("nim c --hints:off " & harness & " 2>&1")
    if exitCode == 0:
      echo "REF_SIMPLE_HARNESS: PASS"
    else:
      echo "REF_SIMPLE_HARNESS: FAIL"
    removeFile(harness)

  block ref_simple_config_flags_valid:
    let harness = tmpdir / "ref_simple_config_test.nim"
    let nims = tmpdir / "ref_simple_config_test.nims"
    writeFile(harness, """
proc initialize(): cint {.exportc: "LLVMFuzzerInitialize".} =
  {.emit: "N_CDECL(void, NimMain)(void); NimMain();".}

proc testOneInput(data: ptr UncheckedArray[byte], len: int): cint {.
    exportc: "LLVMFuzzerTestOneInput", raises: [].} =
  result = 0
""")
    writeFile(nims, """
--cc: clang
--panics: on
--define: noSignalHandler
--define: useMalloc
--noMain: on
--passC: "-fsanitize=fuzzer,address,undefined"
--passL: "-fsanitize=fuzzer,address,undefined"
--debugger: native
""")
    let (_, exitCode) = execCmdEx(
      "nim c --hints:off -o:" & tmpdir / "ref_simple_config_bin " & harness & " 2>&1")
    if exitCode == 0:
      echo "REF_SIMPLE_CONFIG: PASS"
    else:
      echo "REF_SIMPLE_CONFIG: FAIL"
    for f in [harness, nims, tmpdir / "ref_simple_config_bin"]:
      if fileExists(f): removeFile(f)

  block ref_simple_seed_corpus:
    let corpusDir = tmpdir / "ref_simple_corpus"
    createDir(corpusDir)
    writeFile(corpusDir / "seed_01", "FUZ")
    let seedExists = fileExists(corpusDir / "seed_01")
    let seedContent = readFile(corpusDir / "seed_01")
    if seedExists and seedContent == "FUZ":
      echo "REF_SIMPLE_SEED: PASS"
    else:
      echo "REF_SIMPLE_SEED: FAIL"
    removeDir(corpusDir)

main()
