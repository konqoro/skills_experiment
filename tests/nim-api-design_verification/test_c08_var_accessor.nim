## C08: var T accessors are deliberate mutable views.

import std/algorithm

type
  Config = object
    name: string
    tags: seq[string]
    count: int

proc name(c: var Config): var string = result = c.name
proc tags(c: var Config): var seq[string] = result = c.tags
# No var accessor for count; callers assign through the public field here.

block var_string_mutation:
  var c = Config(name: "hello", tags: @[], count: 0)
  c.name().add("!")
  doAssert c.name == "hello!"

block var_seq_mutation:
  var c = Config(name: "", tags: @["b", "a"], count: 0)
  c.tags().sort()
  doAssert c.tags == @["a", "b"]
  c.tags()[0] = "z"
  doAssert c.tags[0] == "z"

block scalars_direct_assignment:
  var c = Config(name: "", tags: @[], count: 10)
  c.count = 20
  doAssert c.count == 20

echo "C08: PASS"
