proc main() =
  # C04: toOpenArray converts a pointer and length to openArray[byte]
  proc sumBytes(data: ptr UncheckedArray[byte], len: int): int =
    result = 0
    for b in data.toOpenArray(0, len-1):
      result += int(b)

  var buf = [1'u8, 2'u8, 3'u8, 4'u8]
  var res = sumBytes(cast[ptr UncheckedArray[byte]](addr buf[0]), buf.len)
  doAssert res == 10
  echo "C04: PASS"

main()
