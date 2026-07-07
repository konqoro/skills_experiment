import std/assertions

type Lookup = object
  data: seq[(string, string)]

func contains(l: Lookup; key: string): bool =
  for item in l.data:
    if item[0] == key:
      return true

func hasKey(l: Lookup; key: string): bool =
  l.contains(key)

func getOrDefault(l: Lookup; key: string; default = ""): string =
  for item in l.data:
    if item[0] == key:
      return item[1]
  default

let l = Lookup(data: @[("name", "Alice"), ("empty", "")])

doAssert l.contains("name")
doAssert l.hasKey("name")
doAssert not l.contains("missing")

doAssert l.getOrDefault("name", "n/a") == "Alice"
doAssert l.getOrDefault("empty", "n/a") == ""
doAssert l.getOrDefault("missing", "n/a") == "n/a"

echo "C39: PASS"
