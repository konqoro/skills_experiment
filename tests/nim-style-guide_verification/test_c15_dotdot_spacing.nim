## C15: Prefer spaces around .. and ..< in slices, loops, and range expressions.
## Range type constructors use .., not ..<: range[0 ..< n] does not compile; range[0 .. n-1] does.

import std/[assertions]

block range_with_spaces:
  const n = 6
  type A = range[0 .. (n - 1)]
  var x: A = 3
  doAssert x == 3

block slice_with_spaces:
  let s = "abcdef"
  doAssert s[0 .. 2] == "abc"
  doAssert s[0 ..< 3] == "abc"

block dotdot_in_for:
  var total = 0
  for i in 0 .. 4:
    total += i
  doAssert total == 10

  var total2 = 0
  for i in 0 ..< 5:
    total2 += i
  doAssert total2 == 10

echo "C15: PASS"
