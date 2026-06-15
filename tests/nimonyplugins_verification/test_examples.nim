# Test the reference examples end-to-end: template, Replacer, type plugins.
import std/[os, osproc, strutils]

let base = getTempDir() / "nimonyplugins_examples"
if dirExists(base):
  removeDir(base)
createDir(base)

proc runNimony(appFile: string): (string, int) =
  result = execCmdEx("nimony c -r " & appFile.quoteShell)

# ── 1. Template plugin: popcount lookup table ───────────────────────

block:
  let d = base / "poplut"; createDir(d)

  writeFile(d / "poplut.nim", """
import plugins
proc popc8(i: int): int =
  var v = i; var c = 0
  while v != 0: v = v and (v - 1); inc c
  c
proc tr(n: NifCursor): NifBuilder =
  result = createTree()
  result.withTree BracketX, n.info:
    for i in 0..<256:
      result.addIntLit popc8(i)
var inp = loadPluginInput()
saveTree tr(inp)
""")

  writeFile(d / "app.nim", """
import std/syncio
import std/assertions
template buildPopcountLut(): untyped {.plugin: "poplut".}
let PopLut: array[256, int] = buildPopcountLut()
assert PopLut[0] == 0
assert PopLut[1] == 1
assert PopLut[13] == 3
assert PopLut[255] == 8
echo "TEMPLATE: PASS"
""")

  let (outp, code) = runNimony(d / "app.nim")
  doAssert code == 0, "Template plugin failed:\n" & outp
  doAssert "TEMPLATE: PASS" in outp, outp
  echo "TEMPLATE: PASS"

# ── 2. Replacer template plugin: privacy audit event ────────────────

block:
  let d = base / "auditprivacy"; createDir(d)

  writeFile(d / "auditplug.nim", """
import plugins
import std/strutils

const PolicyStamp = "policy:privacy-audit-v2"

proc callHeadMatches(n: NifCursor; name: string): bool =
  case n.kind
  of Ident:
    result = n.identText == name
  of Symbol:
    let text = n.symText
    result = text == name or text.startsWith(name & ".") or
        text.endsWith("." & name)
  else:
    result = false

proc isCallTo(n: NifCursor; name: string): bool =
  if n.kind != ParLe or n.exprKind != CallX:
    return false
  var child = firstChild(n)
  result = callHeadMatches(child, name)

proc firstStringArg(n: NifCursor): string =
  if n.kind != ParLe:
    return ""
  var child = firstChild(n)
  if child.hasMore:
    skip child
  if child.hasMore and child.kind == StringLit:
    result = child.stringValue

proc isEmptyTag(r: var Replacer): bool =
  var found = false
  peek r:
    let c = getCursor(r)
    if isCallTo(c, "tag"):
      found = firstStringArg(c) == ""
  result = found

proc redacted(info: LineInfo): NifBuilder =
  result = createTree()
  result.addStrLit "[redacted]"

proc rewriteArg(r: var Replacer) =
  if r.isAtom:
    keep r, Any
  elif isCallTo(getCursor(r), "pii"):
    replace r, CallX, redacted(r.info)
  elif isCallTo(getCursor(r), "internalOnly"):
    drop r, CallX
  elif isEmptyTag(r):
    drop r, CallX
  else:
    loopKeepTag r:
      rewriteArg r

var r = loadReplacer()
replaceHead r, CallS, r.info:
  r.dest.addIdent "auditCommit"
  while getCursor(r).hasMore:
    rewriteArg r
  r.dest.addStrLit PolicyStamp
saveReplacer(r)
""")

  writeFile(d / "auditapi.nim", """
var auditTrail* = ""

proc user*(id: string): string =
  "user:" & id

proc tag*(value: string): string =
  "tag:" & value

proc pii*(value: string): string =
  value

proc internalOnly*(value: string): string =
  value

proc auditCommit*(event, account, detail, label, policy: string) =
  auditTrail.add event
  auditTrail.add "|"
  auditTrail.add account
  auditTrail.add "|"
  auditTrail.add detail
  auditTrail.add "|"
  auditTrail.add label
  auditTrail.add "|"
  auditTrail.add policy
  auditTrail.add "\n"

template auditEvent*() {.varargs, plugin: "auditplug".}
""")

  writeFile(d / "app.nim", """
import std/syncio
import auditapi

auditEvent("payment", user("acct:42"), pii("card:4111"), tag("pci"),
  internalOnly("trace-99"), tag(""))
echo auditTrail
""")

  let (outp, code) = runNimony(d / "app.nim")
  doAssert code == 0, "Privacy audit plugin failed:\n" & outp
  doAssert "payment|user:acct:42|[redacted]|tag:pci|policy:privacy-audit-v2" in outp, outp
  doAssert "card:4111" notin outp, outp
  doAssert "trace-99" notin outp, outp
  echo "REPLACER: PASS"

# ── 3. Type plugin: identity passthrough with paramStr(3) ───────────

block:
  let d = base / "typeplugin"; createDir(d)

  writeFile(d / "traceable.nim", """
type
  Traceable* {.plugin: "traceplugin".} = object
    id*: int
    name*: string
""")

  writeFile(d / "traceplugin.nim", """
import plugins
import std/os
proc transform(n: NifCursor): NifBuilder =
  result = createTree()
  var n = n
  if n.stmtKind == StmtsS:
    n = firstChild(n)
  result.withTree StmtsS, n.info:
    while n.hasMore:
      result.takeTree n
let moduleAst = loadPluginInput()
let typeAst = loadPluginInput(paramStr(3))
discard renderNode(typeAst)
saveTree transform(moduleAst)
""")

  writeFile(d / "app.nim", """
import std/syncio
import traceable
var item = Traceable(id: 1, name: "hello")
item.id = 42
item.name = "world"
echo item.id
echo item.name
""")

  let (outp, code) = runNimony(d / "app.nim")
  doAssert code == 0, "Type plugin failed:\n" & outp
  doAssert "42" in outp, outp
  doAssert "world" in outp, outp
  echo "TYPE: PASS"

echo "ALL_EXAMPLES: PASS"
