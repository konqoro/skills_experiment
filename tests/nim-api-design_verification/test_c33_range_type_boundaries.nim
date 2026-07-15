type
  NaturalOptions = object
    maxDepth: int

  IntOptions = object
    maxDepth: int

proc initNaturalOptions(maxDepth: Natural): NaturalOptions {.noinline.} =
  NaturalOptions(maxDepth: maxDepth)

proc initIntOptions(maxDepth: int): IntOptions {.noinline.} =
  IntOptions(maxDepth: maxDepth)

doAssert sizeof(Natural) == sizeof(int)
doAssert sizeof(NaturalOptions) == sizeof(IntOptions)

let depth = 3
doAssert initNaturalOptions(depth).maxDepth == 3
doAssert initIntOptions(depth).maxDepth == 3

echo "C33: PASS"
