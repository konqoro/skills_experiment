import std/[assertions, os, osproc, strutils]

proc main() =
  if findExe("clang").len == 0:
    echo "C24: SKIP (clang unavailable)"
    return

  let here = parentDir(currentSourcePath())
  let child = here /
    "test_c19_c23_c28_asan_oom_src/test_c19_c23_c28_asan_oom_child.nim"
  let output = getTempDir() / "test_c24_asan_clang"
  let flags = "-fsanitize=address -fno-omit-frame-pointer"
  let command = "nim c --cc:clang --passC:" & flags.quoteShell &
    " --passL:" & flags.quoteShell &
    " -g -d:noSignalHandler -d:useMalloc -o:" & output.quoteShell &
    " " & child.quoteShell

  let built = execCmdEx(command)
  doAssert built.exitCode == 0, built.output

  let executed = execCmdEx(output.quoteShell)
  doAssert executed.exitCode != 0
  doAssert executed.output.contains("AddressSanitizer"), executed.output
  doAssert executed.output.contains("heap-buffer-overflow"), executed.output

  echo "C24: PASS"

main()
