proc main() =
  # C05 + C06: Converting fuzzer byte buffer to string and seq[T]
  proc bytesToString(data: ptr UncheckedArray[byte], len: int): string =
    result = newString(len)
    copyMem(addr result[0], data, len)

  proc bytesToSeqF64(data: ptr UncheckedArray[byte], len: int): seq[float64] =
    let n = len div sizeof(float64)
    if n == 0: return
    result = newSeq[float64](n)
    copyMem(addr result[0], data, n * sizeof(float64))

  block string_conversion:
    var buf = [72'u8, 101'u8, 108'u8, 108'u8, 111'u8]
    let s = bytesToString(cast[ptr UncheckedArray[byte]](addr buf[0]), buf.len)
    doAssert s == "Hello"

  block seq_conversion:
    var f64: float64 = 3.14
    let s = bytesToSeqF64(cast[ptr UncheckedArray[byte]](addr f64), sizeof(float64))
    doAssert s.len == 1
    doAssert s[0] == 3.14

  echo "C05: PASS"
  echo "C06: PASS"

main()
