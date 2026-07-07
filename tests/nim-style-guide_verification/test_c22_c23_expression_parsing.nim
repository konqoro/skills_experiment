import std/assertions

proc foo(x: int): int = x
proc same(x, y: int): bool = x == y
proc accept(cond: bool): bool = cond

block call_syntax_in_compound_expressions:
  doAssert foo(1) == 1
  doAssert accept(same(1, 1))
  doAssert not compiles(foo 1 == 1)
  doAssert not compiles(accept(same 1, 1))

block negated_compound_expressions:
  let a = true
  let b = true
  let xs = @[1, 2, 3]

  doAssert (not a or b) == true
  doAssert not (not (a or b))
  doAssert (not 1 < 2) == true
  doAssert not (not (1 < 2))
  doAssert 4 notin xs
  doAssert (not 4 in xs) == false

echo "C22/C23: PASS"
