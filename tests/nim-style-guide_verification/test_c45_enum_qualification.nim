# Test: C45 - unqualified enum values resolve from type context.
# A field name shared by two enums resolves when the expected type is known:
# proc argument, annotated variable, set literal, comparison. `{.pure.}` fields
# also resolve unqualified because the hidden scope is queried as the last attempt.
import std/assertions
import ./test_c45_pure_enum_fixture

type
  Direction = enum north, east, south, west
  Flip = enum north, south
  Suit {.pure.} = enum hearts, spades

proc go(d: Direction): string = $d

doAssert go(north) == "north"
var seen: set[Direction] = {north, west}
doAssert card(seen) == 2 and west in seen
let flipped: Flip = south
doAssert ord(flipped) == 1
let dir: Direction = north         # annotated variable disambiguates
doAssert dir < east                # comparison works once the type is pinned
doAssert hearts < spades          # pure enum: unqualified still resolves
doAssert ord(collected) == 0      # imported pure enum: unqualified still resolves

echo "C45: PASS"
