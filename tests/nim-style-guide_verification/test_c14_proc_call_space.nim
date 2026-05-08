## C14: No space between proc name and ( when calling with 2+ args.
## foo(1, 2) passes two ints. foo (1, 2) passes a tuple.

import std/[assertions]

proc sum2(a, b: int): int = a + b

block normal_call:
  doAssert(sum2(3, 4) == 7)

block space_call_is_tuple:
  ## With a space, Nim parses (3, 4) as a tuple literal.
  ## sum2 does not accept a tuple, so it would fail to compile.
  doAssert(compiles(sum2(3, 4)) == true)
  doAssert(compiles(sum2 (3, 4)) == false)

block single_arg_space_ok:
  proc double(x: int): int = x * 2
  doAssert(double(5) == 10)
  doAssert(double(5) == 10)

echo "C14: PASS"
