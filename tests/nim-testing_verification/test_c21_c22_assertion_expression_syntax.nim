import std/assertions

proc foo(x: int): int = x
proc same(x, y: int): bool = x == y

block unambiguous_assertion_calls:
  doAssert foo(1) == 1, "parenthesized call before comparison"
  doAssert same(1, 1), "parenthesized multi-argument call"

block grouped_negated_assertions:
  doAssert not (foo(1) < 0), "grouped negated comparison"
  doAssert 4 notin @[1, 2, 3]

  let parsedAsNegatedOperand = not 1 < 2
  let groupedComparison = not (1 < 2)
  doAssert parsedAsNegatedOperand != groupedComparison

echo "C21/C22: PASS"
