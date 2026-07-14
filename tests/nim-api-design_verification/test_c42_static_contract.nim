import std/assertions

proc staticValue(value: static[int]): int =
  value

proc fixedArray(size: static[int]): array[size, int] =
  default(array[size, int])

const fixedValue = 2
var runtimeValue = 2

doAssert staticValue(fixedValue + 1) == 3
doAssert not compiles(staticValue(runtimeValue))

doAssert fixedArray(2).len == 2
doAssert fixedArray(3).len == 3

echo "C42: PASS"
