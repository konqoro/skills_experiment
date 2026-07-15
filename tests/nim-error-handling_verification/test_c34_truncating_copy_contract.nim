import std/assertions

proc copyWhatFits(dst: var seq[byte]; src: openArray[byte]) =
  let size = min(dst.len, src.len)
  for index in 0 ..< size:
    dst[index] = src[index]

block oversized_input_is_truncated:
  var dst = @[0'u8, 0]
  dst.copyWhatFits(@[1'u8, 2, 3])
  doAssert dst == @[1'u8, 2]

block empty_input_is_a_noop:
  var dst = @[1'u8, 2]
  dst.copyWhatFits(newSeq[byte]())
  doAssert dst == @[1'u8, 2]

echo "C34: PASS"
