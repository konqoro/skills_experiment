import std/[os, osproc, strutils]

let tmpDir = getTempDir()
let heapRepro = tmpDir / "defect_analysis_asan_heap.nim"
let signalRepro = tmpDir / "defect_analysis_asan_signal.nim"

writeFile(heapRepro, """
let data = cast[ptr UncheckedArray[byte]](alloc(8))
for i in 0..8:
  data[i] = byte(i)
echo data[8]
dealloc(data)
""")

writeFile(signalRepro, """
var data = cast[ptr UncheckedArray[byte]](nil)
data[0] = 1
""")

proc compileRepro(
    source, output, cache: string;
    useMalloc, noSignalHandler, passLinkerFlags: bool
): tuple[output: string, exitCode: int] =
  var command = "nim c --cc:clang --hints:off --nimcache:" & cache
  if useMalloc:
    command.add " -d:useMalloc"
  if noSignalHandler:
    command.add " -d:noSignalHandler"
  command.add " --passC:\"-fsanitize=address,undefined " &
    "-fno-omit-frame-pointer\""
  if passLinkerFlags:
    command.add " --passL:\"-fsanitize=address,undefined " &
      "-fno-omit-frame-pointer\""
  command.add " -o:" & output & " " & source & " 2>&1"
  result = execCmdEx(command)

proc runRepro(path: string): tuple[output: string, exitCode: int] =
  result = execCmdEx(
    "ASAN_OPTIONS=detect_leaks=0 " & path & " 2>&1")

let fullBinary = tmpDir / "defect_analysis_asan_full"
let fullBuild = compileRepro(
  heapRepro, fullBinary, tmpDir / "defect_analysis_asan_full_cache",
  useMalloc = true, noSignalHandler = true, passLinkerFlags = true)
doAssert fullBuild.exitCode == 0, fullBuild.output
let fullRun = runRepro(fullBinary)
doAssert fullRun.exitCode != 0
doAssert fullRun.output.contains("AddressSanitizer: heap-buffer-overflow")

let defaultAllocatorBinary = tmpDir / "defect_analysis_asan_default_allocator"
let defaultAllocatorBuild = compileRepro(
  heapRepro, defaultAllocatorBinary,
  tmpDir / "defect_analysis_asan_default_allocator_cache",
  useMalloc = false, noSignalHandler = true, passLinkerFlags = true)
doAssert defaultAllocatorBuild.exitCode == 0, defaultAllocatorBuild.output
let defaultAllocatorRun = runRepro(defaultAllocatorBinary)
doAssert defaultAllocatorRun.exitCode == 0
doAssert not defaultAllocatorRun.output.contains("AddressSanitizer")

let missingLinkerBinary = tmpDir / "defect_analysis_asan_missing_linker"
let missingLinkerBuild = compileRepro(
  heapRepro, missingLinkerBinary,
  tmpDir / "defect_analysis_asan_missing_linker_cache",
  useMalloc = true, noSignalHandler = true, passLinkerFlags = false)
doAssert missingLinkerBuild.exitCode != 0

let signalHandlerBinary = tmpDir / "defect_analysis_asan_signal_handler"
let signalHandlerBuild = compileRepro(
  signalRepro, signalHandlerBinary,
  tmpDir / "defect_analysis_asan_signal_handler_cache",
  useMalloc = true, noSignalHandler = false, passLinkerFlags = true)
doAssert signalHandlerBuild.exitCode == 0, signalHandlerBuild.output
let signalHandlerRun = runRepro(signalHandlerBinary)
doAssert signalHandlerRun.exitCode != 0
doAssert signalHandlerRun.output.contains("SIGSEGV: Illegal storage access")

let noSignalHandlerBinary = tmpDir / "defect_analysis_asan_no_signal_handler"
let noSignalHandlerBuild = compileRepro(
  signalRepro, noSignalHandlerBinary,
  tmpDir / "defect_analysis_asan_no_signal_handler_cache",
  useMalloc = true, noSignalHandler = true, passLinkerFlags = true)
doAssert noSignalHandlerBuild.exitCode == 0, noSignalHandlerBuild.output
let noSignalHandlerRun = runRepro(noSignalHandlerBinary)
doAssert noSignalHandlerRun.exitCode != 0
doAssert noSignalHandlerRun.output.contains("AddressSanitizer: SEGV")

echo "C08: PASS"
