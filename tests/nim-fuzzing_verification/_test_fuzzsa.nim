proc testOneInput(data: ptr UncheckedArray[byte], len: int): cint {.
    exportc: "LLVMFuzzerTestOneInput", raises: [].} =
  result = 0
  if len > 0:
    doAssert data[0] == 72'u8  # 'H'

proc initialize(): cint {.exportc: "LLVMFuzzerInitialize".} =
  {.emit: "N_CDECL(void, NimMain)(void); NimMain();".}

when defined(fuzzSa):
  include standalone
import std/[os, strformat]

proc standaloneFuzzTarget* =
  stderr.write &"StandaloneFuzzTarget: running {paramCount()} inputs\n"
  for i in 1..paramCount():
    var buf = readFile(paramStr(i))
    discard testOneInput(cast[ptr UncheckedArray[byte]](cstring(buf)), buf.len)
