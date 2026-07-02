# Negative test for C03: testOneInput with raises: [] must not raise
# This file should FAIL to compile

proc testOneInput(data: ptr UncheckedArray[byte], len: int): cint {.
    cdecl, exportc: "LLVMFuzzerTestOneInput", raises: [].} =
  result = 0
  raise newException(ValueError, "boom")  # ERROR: raises [] prohibits this
