Expose one required lookup, explicit membership, free mutation only for
unconstrained values, and mutation procs for invariant-bearing fields.

```nim
type
  Sku* = distinct string

  Product* = object
    name*: string
    labels*: seq[string]
    stock*: int

  Inventory* = object
    ids: seq[Sku]
    products: seq[Product]

proc `==`*(a, b: Sku): bool {.borrow.}
proc `$`*(sku: Sku): string {.borrow.}

proc raiseMissing(sku: Sku) {.noinline, noreturn.} =
  raise newException(KeyError, "unknown sku: " & $sku)

func findIndex(inventory: Inventory; sku: Sku): int =
  for idx, existing in inventory.ids:
    if existing == sku:
      return idx
  result = -1

func contains*(inventory: Inventory; sku: Sku): bool =
  inventory.findIndex(sku) >= 0

proc add*(inventory: var Inventory; sku: Sku; product: sink Product) =
  if inventory.contains(sku):
    raise newException(ValueError, "duplicate sku")
  inventory.ids.add sku
  inventory.products.add product

proc product*(inventory: Inventory; sku: Sku): lent Product =
  let idx = inventory.findIndex(sku)
  if idx < 0:
    raiseMissing(sku)
  result = inventory.products[idx]

proc labels*(inventory: var Inventory; sku: Sku): var seq[string] =
  let idx = inventory.findIndex(sku)
  if idx < 0:
    raiseMissing(sku)
  result = inventory.products[idx].labels

proc setStock*(inventory: var Inventory; sku: Sku; stock: Natural) =
  let idx = inventory.findIndex(sku)
  if idx < 0:
    raiseMissing(sku)
  inventory.products[idx].stock = stock

let hammer = Sku("hammer")
var inventory: Inventory
inventory.add hammer,
  Product(name: "Hammer", labels: @["tool"], stock: 4)
doAssert inventory.contains(hammer)
doAssert inventory.product(hammer).name == "Hammer"
inventory.labels(hammer).add "steel"
inventory.setStock(hammer, 6)
doAssert inventory.product(hammer).labels.len == 2
doAssert inventory.product(hammer).stock == 6
```

## Key points

- `contains` is the explicit optional path; `product` is the required lookup
  and raises one specific exception.
- The borrowed result is returned directly from owner storage.
- Labels are freely editable, so a `var seq[string]` accessor is appropriate.
- Stock changes use a proc because the public contract constrains the value.
