## C30: compiles(expr) returns true if the expression type-checks,
##      false otherwise.

import std/[assertions]

block compiles_true:
  doAssert compiles(1 + 2) == true

block compiles_false:
  doAssert compiles(1 + "string") == false

block compiles_generic:
  proc foo[T](x: T): int = 1
  doAssert compiles(foo(42)) == true
  doAssert compiles(foo("abc")) == true

block compiles_type:
  doAssert compiles(1.int) == true
  doAssert compiles(1.string) == false

echo "C30: PASS"
