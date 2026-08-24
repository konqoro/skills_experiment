# Test: C46 - `unsafeAddr` is a deprecated alias for `addr`.
# `addr` accepts immutable operands, so every `unsafeAddr x` use site can be
# written as `addr x`: string elements, seq elements as copyMem sources, and
# array elements passed to C-style pointer APIs.
import std/assertions

let s = "abc"
let p = addr s[0]
doAssert p[] == 'a'

let src = @[7.byte, 8, 9]
var dst: array[3, byte]
copyMem(addr dst[0], addr src[0], src.len)
doAssert dst == [7.byte, 8, 9]

let values = [1.cint, 4.cint, 7.cint]
let first = addr values[0]
doAssert first[] == 1

echo "C46: PASS"
