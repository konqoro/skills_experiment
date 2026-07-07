import std/assertions

proc same(x, y: int): bool = x == y

doAssert same 1, 1
