import std/assertions

type Inventory = object
  names: seq[string]

func len(inv: Inventory): int =
  inv.names.len

func find(inv: Inventory; name: string): int =
  for idx, existing in inv.names:
    if existing == name:
      return idx
  result = -1

func contains(inv: Inventory; name: string): bool =
  inv.find(name) >= 0

proc add(inv: var Inventory; name: string) =
  if not inv.contains(name):
    inv.names.add name

proc del(inv: var Inventory; name: string) =
  let idx = inv.find(name)
  if idx >= 0:
    inv.names.delete idx

proc clear(inv: var Inventory) =
  inv.names.setLen 0

var inv: Inventory
doAssert inv.len == 0
doAssert inv.find("hammer") == -1
doAssert not inv.contains("hammer")

inv.add "hammer"
inv.add "nail"
doAssert inv.len == 2
doAssert inv.find("hammer") == 0
doAssert inv.find("nail") == 1
doAssert inv.contains("hammer")

inv.del "hammer"
doAssert inv.find("hammer") == -1
doAssert inv.find("nail") == 0

inv.del "missing"
doAssert inv.len == 1
doAssert inv.find("nail") == 0

var indexed = @[10, 20, 30]
indexed.del 1
doAssert indexed == @[10, 30]

inv.clear()
doAssert inv.len == 0
doAssert inv.find("nail") == -1

echo "C38: PASS"
