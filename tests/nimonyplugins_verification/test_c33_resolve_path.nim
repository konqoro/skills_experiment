# Test C33: resolve plugins.nim path
import std/os

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

let dir = parentDir(real)
let pluginPath = dir / "../src/nimony/lib/plugins.nim"
doAssert fileExists(pluginPath), "Expected plugins.nim at: " & pluginPath

echo "C33: PASS"
