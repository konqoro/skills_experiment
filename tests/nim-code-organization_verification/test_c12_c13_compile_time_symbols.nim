## C12-C13: Compile-time symbols persist for the whole compilation, and a
## module that needs a symbol off must `{.undef: flag.}` it itself.

import std/[os, osproc, strutils]

let workDir = "/tmp/nim_code_organization_c12_c13"
let nimcache = workDir / "nimcache"
removeDir(workDir)
createDir(workDir)
createDir(nimcache)

proc runNim(args: string): tuple[output: string, exitCode: int] =
  execCmdEx("nim " & args)

proc writeFileAt(relPath, source: string): string =
  let path = workDir / relPath
  writeFile(path, source)
  path

let modA = writeFileAt("modA.nim", """
when defined(modeFlag):
  echo "modA: modeFlag is ON"
else:
  echo "modA: modeFlag is OFF"
""")

let modAFixed = writeFileAt("modA_fixed.nim", """
{.undef: modeFlag.}

when defined(modeFlag):
  echo "modA_fixed: modeFlag is ON"
else:
  echo "modA_fixed: modeFlag is OFF"
""")

let modB = writeFileAt("modB.nim", """
{.define: modeFlag.}

when defined(modeFlag):
  echo "modB: modeFlag is ON"
else:
  echo "modB: modeFlag is OFF"
""")

let mainAB = writeFileAt("mainAB.nim", "import modA, modB\n")
let mainBA = writeFileAt("mainBA.nim", "import modB, modA\n")
let mainBAfixed = writeFileAt("mainBA_fixed.nim", "import modB, modA_fixed\n")

let flags = "c -r --nimcache:" & nimcache.quoteShell & " --path:" & workDir.quoteShell & " "

block c12_import_order_changes_behavior:
  let resAB = runNim(flags & mainAB.quoteShell)
  doAssert resAB.exitCode == 0, resAB.output
  doAssert "modA: modeFlag is OFF" in resAB.output, resAB.output
  doAssert "modB: modeFlag is ON" in resAB.output, resAB.output

  let resBA = runNim(flags & mainBA.quoteShell)
  doAssert resBA.exitCode == 0, resBA.output
  doAssert "modA: modeFlag is ON" in resBA.output, resBA.output
  doAssert "modB: modeFlag is ON" in resBA.output, resBA.output

block c13_undef_pins_module_intent:
  let resFixed = runNim(flags & mainBAfixed.quoteShell)
  doAssert resFixed.exitCode == 0, resFixed.output
  doAssert "modA_fixed: modeFlag is OFF" in resFixed.output, resFixed.output
  doAssert "modB: modeFlag is ON" in resFixed.output, resFixed.output

echo "C12_C13: PASS"
