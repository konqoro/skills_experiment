import std/[assertions, hashes, tables]

type
  Sku = distinct string

  Inventory = object
    ids: seq[Sku]
    names: seq[string]

proc `==`(a, b: Sku): bool {.borrow.}
proc `$`(sku: Sku): string {.borrow.}
proc hash(sku: Sku): Hash {.borrow.}

proc add(inv: var Inventory; sku: Sku; name: string) =
  inv.ids.add sku
  inv.names.add name

iterator items(inv: Inventory): string =
  for name in inv.names:
    yield name

iterator pairs(inv: Inventory): (Sku, string) =
  for idx, sku in inv.ids:
    yield (sku, inv.names[idx])

block hash_for_table_key:
  var table: Table[Sku, int]
  table[Sku("hammer")] = 3
  doAssert table[Sku("hammer")] == 3

block standard_container_iterators:
  var inventory: Inventory
  inventory.add Sku("hammer"), "Hammer"
  inventory.add Sku("nail"), "Nail"

  var names: seq[string]
  for name in inventory.items:
    names.add name
  doAssert names == @["Hammer", "Nail"]

  var entries: seq[string]
  for sku, name in inventory.pairs:
    entries.add $sku & ":" & name
  doAssert entries == @["hammer:Hammer", "nail:Nail"]

echo "C36/C37: PASS"
