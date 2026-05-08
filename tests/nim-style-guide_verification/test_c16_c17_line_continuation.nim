## C16: Line continuation is inferred when a line ends in
##      an operator, comma, or opening bracket.
## C17: The continued line must be indented further than the
##      statement that started it.

import std/[assertions]

block continuation_after_operator:
  let x = 1 +
    2 +
    3
  doAssert x == 6

block continuation_after_comma:
  proc add3(a, b, c: int): int = a + b + c
  let y = add3(
    10,
    20,
    30
  )
  doAssert y == 60

block continuation_after_open_bracket:
  let items = @[
    "alpha",
    "beta",
    "gamma"
  ]
  doAssert items.len == 3

block continuation_and_keyword:
  let ok = (true) and
    (true)
  doAssert ok == true

echo "C16_C17: PASS"
