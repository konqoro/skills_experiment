# NifBuilder is move-only. This host-Nim harness asks Nimony to reject a copy.
import std/[os, osproc, strutils]

let base = getTempDir() / "nimonyplugins_builder_copy_negative"
if dirExists(base):
  removeDir(base)
createDir(base)

let source = base / "copy_builder.nim"
let pluginDir = parentDir(currentSourcePath())
let srcLibPath = findExe("nimony").parentDir.parentDir / "src" / "nimony" / "lib"
writeFile(source, """
import plugins
var original = createTree()
original.addIdent "x"
var copied = original
discard copied
""")

let cmd = "nimony c " & quoteShell("--path:" & pluginDir) & " " &
  quoteShell("--path:" & srcLibPath) & " " & quoteShell(source)
let res = execCmdEx(cmd)
doAssert res.exitCode != 0, res.output
doAssert res.output.contains("'=dup' is not available for type <TokenBuf>"),
  res.output
echo "C62_BUILDER_COPY_NEGATIVE: PASS"
