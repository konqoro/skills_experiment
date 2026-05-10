## C13, C14, C15, C19: Constructor surface should stay coherent.

import std/strutils

type
  Catalog = object
    items: seq[string]

  CatalogRef = ref object
    items: seq[string]

const
  DefaultInitialSize = 4

proc initCatalog(initialSize = DefaultInitialSize): Catalog =
  result.items = newSeqOfCap[string](initialSize)

proc newCatalog(initialSize = DefaultInitialSize): CatalogRef =
  new(result)
  result.items = initCatalog(initialSize).items

proc toCatalog(items: openArray[string]): Catalog =
  result = initCatalog(items.len)
  for item in items:
    result.items.add item

proc toCatalog(csv: string): Catalog =
  result = initCatalog()
  for raw in csv.split(','):
    let item = raw.strip()
    if item.len > 0:
      result.items.add item

proc len(c: Catalog): int {.inline.} =
  c.items.len

proc len(c: CatalogRef): int {.inline.} =
  c.items.len

proc item(c: Catalog; i: Natural): lent string {.inline.} =
  c.items[i]

proc item(c: CatalogRef; i: Natural): lent string {.inline.} =
  c.items[i]

block default_constructor_path:
  let empty = initCatalog()
  let emptyRef = newCatalog()
  doAssert empty.len == 0
  doAssert emptyRef.len == 0

block tox_overloads_share_one_name:
  let fromArray = toCatalog(["alpha", "beta"])
  let fromString = toCatalog("gamma, delta")
  doAssert fromArray.len == 2
  doAssert fromArray.item(1) == "beta"
  doAssert fromString.len == 2
  doAssert fromString.item(0) == "gamma"

block ref_surface_keeps_key_accessor_names:
  var byRef = newCatalog(8)
  byRef.items.add "zeta"
  doAssert byRef.len == 1
  doAssert byRef.item(0) == "zeta"
  doAssert compiles(len(initCatalog()))
  doAssert compiles(len(newCatalog()))
  doAssert compiles(item(toCatalog(["x"]), 0))
  doAssert compiles(item(byRef, 0))

echo "C13_C14_C15_C19: PASS"
