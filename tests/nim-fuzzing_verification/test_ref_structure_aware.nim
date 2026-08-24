import std/[os, osproc, strutils]

proc main() =
  let tmpDir = getTempDir()
  let harness = tmpDir / "ref_structure_aware.nim"
  let binary = tmpDir / "ref_structure_aware"

  writeFile(harness, """
import std/random

type
  Frame = object
    kind: byte
    payload: seq[byte]

proc decodeFrame(input: openArray[byte]; frame: var Frame): bool =
  result = input.len >= 2
  if result:
    let payloadLen = int(input[1])
    result = payloadLen == input.len - 2
    if result:
      frame.kind = input[0]
      frame.payload = newSeq[byte](payloadLen)
      if payloadLen > 0:
        copyMem(addr frame.payload[0], addr input[2], payloadLen)

proc processFrame(input: openArray[byte]) =
  var frame: Frame
  if not decodeFrame(input, frame):
    raise newException(ValueError, "invalid frame")
  if frame.kind > 3:
    raise newException(ValueError, "unknown frame kind")

  case frame.kind
  of 0:
    discard
  of 1:
    if frame.payload.len != 4:
      raise newException(ValueError, "invalid ping")
  of 2:
    if frame.payload.len == 0:
      raise newException(ValueError, "empty data frame")
  of 3:
    if frame.payload.len > 32:
      raise newException(ValueError, "control frame too large")
  else:
    discard

proc encodeFrame(
    frame: Frame;
    data: ptr UncheckedArray[byte];
    maxLen: int
): int =
  result = 0
  if maxLen >= 2 and
      frame.payload.len <= 255 and
      frame.payload.len <= maxLen - 2:
    data[0] = frame.kind
    data[1] = byte(frame.payload.len)
    if frame.payload.len > 0:
      copyMem(addr data[2], addr frame.payload[0], frame.payload.len)
    result = frame.payload.len + 2

proc testOneInput(data: ptr UncheckedArray[byte], len: int): cint {.
    cdecl, exportc: "LLVMFuzzerTestOneInput", raises: [].} =
  result = 0
  try:
    processFrame(data.toOpenArray(0, len - 1))
  except ValueError:
    discard

proc customMutator(
    data: ptr UncheckedArray[byte];
    len, maxLen: int;
    seed: int64
): int {.cdecl, exportc: "LLVMFuzzerCustomMutator", raises: [].} =
  var frame: Frame
  if not decodeFrame(data.toOpenArray(0, len - 1), frame):
    frame = Frame(kind: 0)

  var rng = initRand(seed)
  let maxPayloadLen = min(255, max(0, maxLen - 2))
  case rng.rand(3)
  of 0:
    frame.kind = byte(rng.rand(0..3))
  of 1:
    if frame.payload.len > 0:
      let index = rng.rand(0..<frame.payload.len)
      frame.payload[index] = byte(rng.rand(255))
  of 2:
    if frame.payload.len < maxPayloadLen:
      frame.payload.add byte(rng.rand(255))
  of 3:
    if frame.payload.len > 0:
      frame.payload.setLen(frame.payload.len - 1)
  else:
    discard

  result = encodeFrame(frame, data, maxLen)
  if result == 0:
    result = len

proc initialize(): cint {.cdecl, exportc: "LLVMFuzzerInitialize".} =
  {.emit: "N_CDECL(void, NimMain)(void); NimMain();".}
""")

  let (buildOut, buildExit) = execCmdEx(
    "nim c --cc:clang --panics:on --noMain:on " &
    "-d:noSignalHandler -d:useMalloc " &
    "--passC:\"-fsanitize=fuzzer,address,undefined\" " &
    "--passL:\"-fsanitize=fuzzer,address,undefined\" " &
    "--hints:off -o:" & binary & " " & harness & " 2>&1")

  doAssert buildExit == 0, buildOut
  let (runOut, runExit) = execCmdEx(
    "ASAN_OPTIONS=detect_leaks=0 " & binary &
    " -runs=10000 -max_len=257 -artifact_prefix=" & tmpDir & "/ 2>&1")
  doAssert runExit == 0, runOut
  doAssert runOut.contains("LLVMFuzzerCustomMutator")

  for path in [harness, binary]:
    if fileExists(path):
      removeFile(path)

  echo "REF_STRUCTURE_AWARE: PASS"

main()
