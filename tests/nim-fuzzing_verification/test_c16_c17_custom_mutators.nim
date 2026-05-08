proc main() =
  # C16 + C17: customMutator and customCrossOver must compile with correct signatures
  block customMutator_signature:
    proc customMutator(data: ptr UncheckedArray[byte], len, maxLen: int,
        seed: int64): int {.exportc: "LLVMFuzzerCustomMutator", raises: [].} =
      result = len

    var buf: array[16, byte]
    let r = customMutator(cast[ptr UncheckedArray[byte]](addr buf[0]), 4, 16, 42)
    doAssert r == 4
    doAssert r <= 16

  block customCrossOver_signature:
    proc customCrossOver(data1: ptr UncheckedArray[byte], len1: int,
        data2: ptr UncheckedArray[byte], len2: int,
        res: ptr UncheckedArray[byte], maxResLen: int,
        seed: int64): int {.exportc: "LLVMFuzzerCustomCrossOver", raises: [].} =
      let n = min(len1, len2)
      if n > 0 and n <= maxResLen:
        copyMem(res, data1, n)
        result = n
      else:
        result = 0

    var buf1 = [1'u8, 2'u8, 3'u8]
    var buf2 = [4'u8, 5'u8, 6'u8]
    var resbuf: array[8, byte]
    let r = customCrossOver(
      cast[ptr UncheckedArray[byte]](addr buf1[0]), 3,
      cast[ptr UncheckedArray[byte]](addr buf2[0]), 3,
      cast[ptr UncheckedArray[byte]](addr resbuf[0]), 8, 99)
    doAssert r == 3
    doAssert r <= 8
    doAssert resbuf[0] == 1'u8

  echo "C16: PASS"
  echo "C17: PASS"

main()
