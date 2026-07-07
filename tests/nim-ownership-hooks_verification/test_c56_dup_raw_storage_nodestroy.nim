import std/assertions

type
  Counted = object
    val: int
    dupCount: ptr int

  Bag = object
    items: ptr UncheckedArray[Counted]
    len: int

var sinkCount = 0

proc `=destroy`(x: Counted) =
  discard

proc `=wasMoved`(x: var Counted) =
  x.dupCount = nil

proc `=sink`(dest: var Counted; src: Counted) =
  inc sinkCount
  dest.val = src.val
  dest.dupCount = src.dupCount

proc `=copy`(dest: var Counted; src: Counted) =
  dest.val = src.val
  dest.dupCount = src.dupCount

proc `=dup`(x: Counted): Counted {.nodestroy.} =
  result = Counted(val: x.val, dupCount: x.dupCount)
  if x.dupCount != nil:
    inc x.dupCount[]

proc `=destroy`(b: Bag) =
  if b.items != nil:
    for i in 0..<b.len:
      `=destroy`(b.items[i])
    dealloc(b.items)

proc `=wasMoved`(b: var Bag) =
  b.items = nil
  b.len = 0

proc dupBagPlain(b: Bag): Bag =
  result = Bag(len: b.len, items: nil)
  if b.items != nil and b.len > 0:
    result.items =
      cast[ptr UncheckedArray[Counted]](alloc(b.len * sizeof(Counted)))
    for i in 0..<b.len:
      result.items[i] = `=dup`(b.items[i])

proc dupBagNoDestroy(b: Bag): Bag {.nodestroy.} =
  result = Bag(len: b.len, items: nil)
  if b.items != nil and b.len > 0:
    result.items =
      cast[ptr UncheckedArray[Counted]](alloc(b.len * sizeof(Counted)))
    for i in 0..<b.len:
      result.items[i] = `=dup`(b.items[i])

block raw_storage_dup_slots:
  var dupCounter = 0
  var b = Bag(
    len: 1,
    items: cast[ptr UncheckedArray[Counted]](alloc(sizeof(Counted))))
  b.items[0] = Counted(val: 42, dupCount: addr dupCounter)

  sinkCount = 0
  dupCounter = 0
  var plain = dupBagPlain(b)
  doAssert dupCounter == 1
  doAssert sinkCount == 1

  sinkCount = 0
  dupCounter = 0
  var noDestroy = dupBagNoDestroy(b)
  doAssert dupCounter == 1
  doAssert sinkCount == 0

echo "C56: PASS"
