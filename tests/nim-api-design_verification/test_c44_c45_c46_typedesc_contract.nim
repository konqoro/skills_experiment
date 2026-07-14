import std/assertions

proc makeDefault(T: typedesc): T =
  default(T)

proc acceptsAny(A, B: typedesc): bool =
  true

proc acceptsSame[T](A, B: typedesc[T]): bool =
  true

doAssert int.makeDefault == 0
doAssert string.makeDefault == ""
doAssert acceptsAny(int, string)
doAssert compiles(acceptsSame(int, int))
doAssert not compiles(acceptsSame(int, string))

echo "C44-C46: PASS"
