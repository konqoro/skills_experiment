proc total(values: openArray[int]): int =
  for value in values:
    result += value

proc appendValue(values: var seq[int]; value: int) =
  values.add value

proc replaceFirst(values: var openArray[int]; value: int) =
  values[0] = value

static:
  doAssert not compiles(
    block:
      proc resizeBatch(values: openArray[int]) =
        values.setLen(0)
  )
  doAssert not compiles(
    block:
      proc replaceBatch(values: openArray[int]) =
        values = [4, 5]
  )
  doAssert not compiles(
    block:
      proc mutateBatch(values: openArray[int]) =
        values[0] = 4
  )
  doAssert not compiles(
    block:
      proc resizeMutableBatch(values: var openArray[int]) =
        values.setLen(0)
  )
  doAssert not compiles(
    block:
      proc replaceMutableBatch(values: var openArray[int]) =
        values = [4, 5]
  )
  doAssert not compiles(
    block:
      proc resizeImmutableSeq(values: seq[int]) =
        values.add 4
  )

let valuesArray = [1, 2, 3]
let valuesSeq = @[1, 2, 3]

doAssert total(valuesArray) == 6
doAssert total(valuesSeq) == 6
doAssert total([1, 2, 3]) == 6

var callerArray = [1, 2]
replaceFirst(callerArray, 3)
doAssert callerArray == [3, 2]

var callerValues = @[1, 2]
replaceFirst(callerValues, 4)
doAssert callerValues == @[4, 2]
appendValue(callerValues, 3)
doAssert callerValues == @[4, 2, 3]

echo "C27: PASS"
