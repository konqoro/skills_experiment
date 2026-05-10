## C10 companion: this file demonstrates that a lent accessor using a
## temp local fails to compile under ORC due to escaping borrow.

type
  Data = object
    items: seq[string]

proc itemViaTemp(d: Data; i: int): lent string =
  let temp = d.items[i]
  result = temp

discard itemViaTemp(Data(items: @["test"]), 0)
