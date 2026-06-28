# Test C33: resolve plugins.nim path
import std / [os, strutils]

proc pluginApiPath(executable: string): string =
  let dir = parentDir(executable)
  if executable.endsWith("/bin/nimony"):
    result = dir / "../src/nimony/lib/plugins.nim"
  else:
    result = dir / "src/nimony/lib/plugins.nim"

let exePath = findExe("nimony")
doAssert exePath.len > 0

# Resolve symlinks step by step
var real = exePath
while true:
  try:
    let target = expandSymlink(real)
    if target == "": break
    if isAbsolute(target): real = target
    else: real = parentDir(real) / target
  except OSError:
    break

let pluginPath = pluginApiPath(real)
doAssert fileExists(pluginPath), "Expected plugins.nim at: " & pluginPath

doAssert normalizedPath(pluginApiPath("/opt/nimony/bin/nimony")) ==
  "/opt/nimony/src/nimony/lib/plugins.nim"
doAssert normalizedPath(pluginApiPath("/opt/nimony/nimony")) ==
  "/opt/nimony/src/nimony/lib/plugins.nim"

echo "C33: PASS"
