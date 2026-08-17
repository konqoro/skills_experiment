type
  InventoryState = object
    onHand: int
    reserved: int

func initInventory(onHand: int): InventoryState =
  InventoryState(onHand: max(onHand, 0))

func available(state: InventoryState): int =
  state.onHand - state.reserved

proc check(state: InventoryState) =
  assert state.reserved >= 0 and state.reserved <= state.onHand

proc restock(state: var InventoryState; quantity: int) =
  if quantity > 0:
    inc state.onHand, quantity
    check state

proc reserve(state: var InventoryState; quantity: int): bool =
  if quantity > 0 and quantity <= state.available:
    inc state.reserved, quantity
    check state
    result = true

proc cancelReservation(state: var InventoryState; quantity: int): bool =
  if quantity > 0 and quantity <= state.reserved:
    dec state.reserved, quantity
    check state
    result = true

proc shipReserved(state: var InventoryState; quantity: int): bool =
  if quantity > 0 and quantity <= state.reserved:
    dec state.reserved, quantity
    dec state.onHand, quantity
    check state
    result = true

proc countNonEmpty(names: openArray[string]): int =
  for name in names:
    if name.len > 0:
      inc result

var inventory = initInventory(5)
doAssert inventory.available == 5
doAssert inventory.reserve(3)
doAssert inventory.available == 2
doAssert not inventory.reserve(3)
inventory.restock(4)
doAssert inventory.available == 6
doAssert inventory.shipReserved(2)
doAssert inventory.available == 6
doAssert inventory.cancelReservation(1)
doAssert inventory.available == 7
doAssert inventory.reserved == 0
doAssert inventory.onHand == 7
doAssert countNonEmpty(["alpha", "", "beta"]) == 2

echo "ref_orchestration_pattern: PASS"
