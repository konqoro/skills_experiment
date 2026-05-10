## C13: No space before [ in type annotations.
## Positive test: array[0..4, bool] compiles and works.

import std/[assertions, tables]

block array_no_space:
  var foo: array[0 .. 4, bool]
  doAssert(foo.len == 5)

block seq_no_space:
  var bar: seq[int]
  doAssert(bar.len == 0)

block table_no_space:
  var t: Table[string, int]
  doAssert(t.len == 0)

echo "C13: PASS"
