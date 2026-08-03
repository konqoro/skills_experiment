# Test: C39 - expression-bodied funcs vs result-based multi-statement bodies
import std/assertions

type Bag = object
  items: seq[string]

# If the body is exactly one expression, end with that expression.
func len(b: Bag): int = b.items.len

# Otherwise build the return value in `result` at the end of the body,
# one assignment, or one per branch.
func sign(x: int): string =
  if x < 0:
    result = "neg"
  elif x > 0:
    result = "pos"
  else:
    result = "zero"

let bag = Bag(items: @["a", "b", "c"])
doAssert len(bag) == 3
doAssert bag.len == 3
doAssert sign(-1) == "neg"
doAssert sign(0) == "zero"
doAssert sign(2) == "pos"

echo "C39: PASS"
