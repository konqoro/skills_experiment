type
  Item = object
    value: int

proc inspect(item: lent Item): int =
  item.value

echo inspect(Item(value: 1))
