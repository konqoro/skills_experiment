## C12: `{.define.}`/`{.undef.}` do not scope behavior across modules. A proc
## bakes its `when defined(flag)` branch at its own definition site, so a later
## module cannot change it by wrapping a call with define/undef. Use a runtime
## parameter to scope behavior per call.

import std/[os, osproc, strutils]

let workDir = "/tmp/nim_code_organization_c12"
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

# modA: parseC branches on a compile-time flag (the cross-module approach);
# parseR takes a runtime flag (the working approach).
let modA = writeFileAt("modA.nim", """
proc parseC*(s: string): string =
  when defined(modeFlag):
    "ON"
  else:
    if s.len == 0: raise newException(ValueError, "empty")
    "OFF"

proc parseR*(s: string, flag: bool): string =
  if s.len == 0 and not flag:
    raise newException(ValueError, "empty")
  if flag: "ON" else: "OFF"
""")

# modB: tries to scope leniency to chatParse by wrapping the parseC call with
# define/undef. This must NOT change parseC, which was compiled in modA with
# the flag off.
let modB = writeFileAt("modB.nim", """
import modA

{.define: modeFlag.}

proc chatParseC*(body: string): string =
  try:
    parseC(body)
  except CatchableError:
    "caught"

{.undef: modeFlag.}

proc chatParseR*(body: string, flag: bool): string =
  try:
    parseR(body, flag)
  except CatchableError:
    "caught"
""")

let main = writeFileAt("main.nim", """
import modB

echo "compile_chat=" & chatParseC("")
echo "runtime_strict=" & chatParseR("", false)
echo "runtime_lenient=" & chatParseR("", true)
""")

let flags = "c -r --nimcache:" & nimcache.quoteShell & " --path:" & workDir.quoteShell & " "

block c12_define_undef_does_not_scope_across_modules:
  let res = runNim(flags & main.quoteShell)
  doAssert res.exitCode == 0, res.output
  # define/undef in modB did not reach parseC: it still raises, the wrapper
  # catches and returns "caught". This is the failure the rule warns against.
  doAssert "compile_chat=caught" in res.output, res.output
  # A runtime parameter scopes the behavior per call.
  doAssert "runtime_strict=caught" in res.output, res.output
  doAssert "runtime_lenient=ON" in res.output, res.output

echo "C12: PASS"
