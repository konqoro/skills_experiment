import std/[assertions, os, osproc]

let tmpDir = getTempDir()
let source = tmpDir / "test_c21_child.nim"
let output = tmpDir / "test_c21_passc_only"

writeFile(source, """
let memory = alloc(16)
let values = cast[ptr UncheckedArray[int]](memory)
values[0] = 42
discard values[5]
dealloc(memory)
""")

let flags = "-fsanitize=address -fno-omit-frame-pointer"
let command = "nim c --passC:" & flags.quoteShell &
  " -d:noSignalHandler -d:useMalloc -o:" & output.quoteShell &
  " " & source.quoteShell
let built = execCmdEx(command)

doAssert built.exitCode != 0,
  "ASan unexpectedly linked without --passL:\n" & built.output
echo "C21: PASS"
