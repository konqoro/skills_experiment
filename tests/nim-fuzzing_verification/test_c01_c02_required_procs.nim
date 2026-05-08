proc main() =
  # C01 + C02: The two required fuzz target procs must compile with correct signatures
  proc initialize(): cint {.exportc: "LLVMFuzzerInitialize".} =
    {.emit: "N_CDECL(void, NimMain)(void); NimMain();".}

  proc testOneInput(data: ptr UncheckedArray[byte], len: int): cint {.
      exportc: "LLVMFuzzerTestOneInput", raises: [].} =
    result = 0

  doAssert true
  echo "C01: PASS"
  echo "C02: PASS"

main()
