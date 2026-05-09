import std/[os, osproc, strutils]

proc main() =
  let tmpdir = getTempDir()

  block ref_struct_harness_compiles:
    let harness = tmpdir / "ref_struct_harness.nim"
    writeFile(harness, """
import std/[random, fenv, math]

proc sum(x: openArray[float]): float =
  result = 0.0
  for b in items(x):
    result = if isNaN(b): result else: result + b

proc quitOrDebug() {.noreturn, importc: "abort", header: "<stdlib.h>", nodecl.}

proc testOneInput(data: ptr UncheckedArray[byte], len: int): cint {.
    exportc: "LLVMFuzzerTestOneInput", raises: [].} =
  result = 0
  let cLen = len div sizeof(float)
  if cLen == 0: return
  var copy = newSeq[float](cLen)
  copyMem(addr copy[0], data, copy.len * sizeof(float))
  let res = sum(copy)
  if isNaN(res):
    quitOrDebug()

proc initialize(): cint {.exportc: "LLVMFuzzerInitialize".} =
  {.emit: "N_CDECL(void, NimMain)(void); NimMain();".}
""")
    let (_, exitCode) = execCmdEx("nim c --hints:off " & harness & " 2>&1")
    if exitCode == 0:
      echo "REF_STRUCT_HARNESS: PASS"
    else:
      echo "REF_STRUCT_HARNESS: FAIL"
    removeFile(harness)

  block ref_struct_custom_mutator:
    let harness = tmpdir / "ref_struct_mutator.nim"
    writeFile(harness, """
import std/[random, fenv, math]

proc randFloat(gen: var Rand): float =
  case gen.rand(10)
  of 0: result = NaN
  of 1: result = minimumPositiveValue(float)
  of 2: result = maximumPositiveValue(float)
  of 3: result = -minimumPositiveValue(float)
  of 4: result = -maximumPositiveValue(float)
  of 5: result = epsilon(float)
  of 6: result = -epsilon(float)
  of 7: result = Inf
  of 8: result = -Inf
  of 9: result = 0.0
  else: result = gen.rand(-1.0..1.0)

proc customMutator(data: ptr UncheckedArray[byte], len, maxLen: int,
    seed: int64): int {.exportc: "LLVMFuzzerCustomMutator", raises: [].} =
  let cLen = len div sizeof(float)
  if cLen == 0:
    var tmp = @[1.0, 3.0, 3.0, 7.0]
    result = tmp.len * sizeof(float)
    copyMem(data, addr tmp[0], result)
    return
  var copy = newSeq[float](cLen)
  copyMem(addr copy[0], data, copy.len * sizeof(float))
  var gen = initRand(seed)
  case gen.rand(3)
  of 0:
    if copy.len > 0:
      copy[gen.rand(0..<copy.len)] = randFloat(gen)
  of 1:
    copy.add randFloat(gen)
  of 2:
    if copy.len > 0: discard copy.pop
  else:
    gen.shuffle(copy)
  result = copy.len * sizeof(float)
  if result <= maxLen:
    copyMem(data, addr copy[0], result)
  else:
    result = 0
""")
    let (_, exitCode) = execCmdEx("nim c --hints:off " & harness & " 2>&1")
    if exitCode == 0:
      echo "REF_STRUCT_MUTATOR: PASS"
    else:
      echo "REF_STRUCT_MUTATOR: FAIL"
    removeFile(harness)

  block ref_struct_custom_crossover:
    let harness = tmpdir / "ref_struct_crossover.nim"
    writeFile(harness, """
import std/[random, math]

proc customCrossOver(data1: ptr UncheckedArray[byte], len1: int,
    data2: ptr UncheckedArray[byte], len2: int,
    res: ptr UncheckedArray[byte], maxResLen: int,
    seed: int64): int {.exportc: "LLVMFuzzerCustomCrossOver", raises: [].} =
  let cLen1 = len1 div sizeof(float)
  if cLen1 == 0: return
  var copy1 = newSeq[float](cLen1)
  copyMem(addr copy1[0], data1, copy1.len * sizeof(float))
  let cLen2 = len2 div sizeof(float)
  if cLen2 == 0: return
  var copy2 = newSeq[float](cLen2)
  copyMem(addr copy2[0], data2, copy2.len * sizeof(float))
  let len = min(copy1.len, min(copy2.len, maxResLen div sizeof(float)))
  if len == 0: return
  var buf = newSeq[float](len)
  var gen = initRand(seed)
  for i in 0 ..< buf.len:
    buf[i] = if gen.rand(1.0) <= 0.5: copy1[i] else: copy2[i]
  result = buf.len * sizeof(float)
  assert result <= maxResLen
  copyMem(res, addr buf[0], result)
""")
    let (_, exitCode) = execCmdEx("nim c --hints:off " & harness & " 2>&1")
    if exitCode == 0:
      echo "REF_STRUCT_CROSSOVER: PASS"
    else:
      echo "REF_STRUCT_CROSSOVER: FAIL"
    removeFile(harness)

main()
