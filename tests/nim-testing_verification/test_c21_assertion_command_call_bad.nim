import std/assertions

proc foo(x: int): int = x

doAssert foo 1 == 1
