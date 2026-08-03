# Test: C38 - one-expression forwarders and field accessors marked {.inline.}
import std/assertions

type Product = object
  name: string

# One-expression field accessor marked inline
proc productName(p: Product): string {.inline.} = p.name

# One-expression forwarder marked inline
proc inner(x: int): int = x * 2
proc doubled(x: int): int {.inline.} = inner(x)

# Accessor written as a single-expression body, also marked inline
proc label(p: Product): string {.inline.} =
  p.name

let p = Product(name: "widget")
doAssert productName(p) == "widget"
doAssert label(p) == "widget"
doAssert doubled(21) == 42

# {.inline.} is accepted on procs that raise; the skill rule to skip it there
# is performance guidance, not a compiler restriction.
proc raiseInline(x: int): int {.inline.} =
  if x < 0:
    raise newException(ValueError, "negative")
  x

doAssert raiseInline(5) == 5

echo "C38: PASS"
