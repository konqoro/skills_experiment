proc testOneInput(data: ptr UncheckedArray[byte], len: int): cint {.
    exportc: "LLVMFuzzerTestOneInput", raises: [].} =
  result = 0
  if len >= 4 and data[0].char == 'C' and data[1].char == 'R' and
     data[2].char == 'A' and data[3].char == 'S':
    quit(1)

proc initialize(): cint {.exportc: "LLVMFuzzerInitialize".} =
  {.emit: "N_CDECL(void, NimMain)(void); NimMain();".}
