# Test: C41 - always initialize `result` explicitly. The implicit `result`
# starts at the type's zero value (declared field defaults apply only through
# the constructor), and a statement-list body returns its last expression
# implicitly today. Do not rely on either behavior.
type W = object
  retryLimit: int = 3
  label: string = "worker"

proc fieldMutationOnly(): W =
  result.retryLimit = 5

proc initializedThenMutated(): W =
  result = W()
  result.retryLimit = 5

proc assignsResultExplicitly(): int =
  var acc = 0
  for i in 1 .. 3:
    acc.inc(i)
  result = acc

# Current Nim 2.3.1 behavior, documented so a future behavior change breaks
# this test: the last expression of a statement-list body is returned
# implicitly, and a body ending in a void statement returns the zero `result`.
proc endsWithExpression(): int =
  let x = 21
  x * 2

proc endsWithVoidStatement(): int =
  let x = 21
  discard x * 2

doAssert fieldMutationOnly().retryLimit == 5
doAssert fieldMutationOnly().label == ""            # zero: declared defaults lost
doAssert initializedThenMutated().retryLimit == 5
doAssert initializedThenMutated().label == "worker" # constructor-applied defaults
doAssert assignsResultExplicitly() == 6
doAssert endsWithExpression() == 42                 # implicit last-expression return
doAssert endsWithVoidStatement() == 0               # silent zero `result`

echo "C41: PASS"
