import std/[os, osproc, strutils]

let here = parentDir(currentSourcePath())
let tmpDir = getTempDir()
let overflowSource = here /
  "test_c19_c23_c28_asan_oom_src/test_c19_c23_c28_asan_oom_child.nim"
let signalSource = here /
  "test_c19_c23_c28_asan_oom_src/test_c23_signal_child.nim"
let sanitizerFlags = "-fsanitize=address -fno-omit-frame-pointer"

proc compile(source, output: string;
    useMalloc, noSignalHandler: bool): tuple[output: string, exitCode: int] =
  var command = "nim c --passC:" & sanitizerFlags.quoteShell &
    " --passL:" & sanitizerFlags.quoteShell & " -g"
  if useMalloc:
    command.add " -d:useMalloc"
  if noSignalHandler:
    command.add " -d:noSignalHandler"
  command.add " -o:" & output.quoteShell & " " & source.quoteShell
  result = execCmdEx(command)

proc run(binary: string): tuple[output: string, exitCode: int] =
  execCmdEx(binary.quoteShell)

block fullRecipe:
  let binary = tmpDir / "test_asan_full"
  let built = compile(overflowSource, binary, true, true)
  doAssert built.exitCode == 0, built.output
  let executed = run(binary)
  doAssert executed.exitCode != 0
  doAssert executed.output.contains("AddressSanitizer")
  doAssert executed.output.contains("heap-buffer-overflow")
  doAssert executed.output.contains(".nim:")
  echo "C19_C28: PASS"

block useMallocNegativeControl:
  let binary = tmpDir / "test_asan_without_usemalloc"
  let built = compile(overflowSource, binary, false, true)
  doAssert built.exitCode == 0, built.output
  let executed = run(binary)
  doAssert not executed.output.contains("heap-buffer-overflow")
  echo "C31: PASS"

block noSignalHandlerNegativeControl:
  let handledBinary = tmpDir / "test_asan_with_nim_signal_handler"
  let handledBuild = compile(signalSource, handledBinary, true, false)
  doAssert handledBuild.exitCode == 0, handledBuild.output
  let handledRun = run(handledBinary)
  doAssert handledRun.exitCode != 0
  doAssert handledRun.output.contains("SIGSEGV")
  doAssert not handledRun.output.contains("AddressSanitizer:DEADLYSIGNAL")

  let asanBinary = tmpDir / "test_asan_without_nim_signal_handler"
  let asanBuild = compile(signalSource, asanBinary, true, true)
  doAssert asanBuild.exitCode == 0, asanBuild.output
  let asanRun = run(asanBinary)
  doAssert asanRun.exitCode != 0
  doAssert asanRun.output.contains("AddressSanitizer:DEADLYSIGNAL")
  doAssert asanRun.output.contains("test_c23_signal_child.nim")
  echo "C23: PASS"
