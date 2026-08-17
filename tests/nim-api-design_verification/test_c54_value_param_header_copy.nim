import std/tables

var countedCopies = 0

type
  Counted = object
    data: seq[int]

proc `=copy`(dest: var Counted; src: Counted) =
  inc countedCopies
  dest.data = src.data

proc countedLen(c: Counted): int =
  c.data.len

proc countedModified(c: Counted): Counted =
  var local = c
  local.data.add 99
  local

proc appendBang(s: string): string =
  var local = s
  local.add '!'
  local

proc grow(xs: seq[int]): seq[int] =
  var local = xs
  local.add 99
  local

proc tableLen(t: Table[string, int]): int =
  t.len

proc test() =
  var c = Counted(data: @[1, 2, 3])
  doAssert countedLen(c) == 3
  doAssert countedCopies == 0, "read-only value param must not copy"

  let grown = countedModified(c)
  doAssert grown.data == @[1, 2, 3, 99]
  doAssert c.data == @[1, 2, 3], "callee copy must not affect caller"
  doAssert countedCopies == 1

  var s = "hello"
  doAssert appendBang(s) == "hello!"
  doAssert s == "hello", "callee copy must not affect caller's string"

  var xs = @[1, 2]
  doAssert grow(xs) == @[1, 2, 99]
  doAssert xs == @[1, 2]

  var t = {"a": 1, "b": 2}.toTable
  doAssert tableLen(t) == 2
  doAssert t.len == 2, "table param must not consume or alter caller's table"

test()

echo "C54: PASS"
