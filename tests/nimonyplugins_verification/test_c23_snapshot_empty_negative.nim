# Test C23: snapshot on an empty NifBuilder asserts at runtime.
import std/[os, osproc, strutils]

proc main() =
  let base = getTempDir() / "nimonyplugins_snapshot_empty"
  createDir(base)
  let src = base / "snapshot_empty.nim"
  let pluginDir = parentDir(currentSourcePath())
  let srcLibPath = findExe("nimony").parentDir.parentDir / "src" / "nimony" / "lib"

  writeFile(src, """
import std/[syncio, assertions]
import plugins
var t = createTree()
discard snapshot(t)
""")

  let cmd = "nimony c -r " & quoteShell("--path:" & pluginDir) & " " &
      quoteShell("--path:" & srcLibPath) & " " & quoteShell(src)
  let res = execCmdEx(cmd)
  doAssert res.exitCode != 0
  doAssert res.output.contains("cannot snapshot empty NifBuilder")

  echo "C23: PASS"

main()
