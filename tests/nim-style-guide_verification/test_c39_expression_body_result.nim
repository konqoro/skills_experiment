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

# A default set at the start may be overridden by the branch that produces
# the value; if no branch fires, the default survives.
func pick(x: int): string =
  result = "default"
  if x > 0:
    result = "positive"
  if x < 0:
    result = "negative"

let bag = Bag(items: @["a", "b", "c"])
doAssert len(bag) == 3
doAssert bag.len == 3
doAssert sign(-1) == "neg"
doAssert sign(0) == "zero"
doAssert sign(2) == "pos"
doAssert pick(0) == "default"
doAssert pick(1) == "positive"
doAssert pick(-1) == "negative"

echo "C39: PASS"
