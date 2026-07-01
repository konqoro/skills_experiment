type
  NaturalOptions = object
    maxDepth: Natural

  IntOptions = object
    maxDepth: int

proc acceptNatural(maxDepth: Natural): int {.noinline.} =
  maxDepth

proc naturalFieldFromInt(maxDepth: int): NaturalOptions {.noinline.} =
  NaturalOptions(maxDepth: maxDepth)

proc naturalFieldFromNatural(maxDepth: Natural): NaturalOptions {.noinline.} =
  NaturalOptions(maxDepth: maxDepth)

proc intFieldFromNatural(maxDepth: Natural): IntOptions {.noinline.} =
  IntOptions(maxDepth: maxDepth)

doAssert sizeof(NaturalOptions) == sizeof(IntOptions)

var negative = -1

when compileOption("rangeChecks"):
  var parameterRejected = false
  try:
    discard acceptNatural(negative)
  except RangeDefect:
    parameterRejected = true
  doAssert parameterRejected

  var fieldRejected = false
  try:
    discard naturalFieldFromInt(negative)
  except RangeDefect:
    fieldRejected = true
  doAssert fieldRejected

else:
  doAssert acceptNatural(negative) == -1
  doAssert naturalFieldFromInt(negative).maxDepth == -1

doAssert naturalFieldFromNatural(Natural(3)).maxDepth == 3
doAssert intFieldFromNatural(Natural(3)).maxDepth == 3

echo "C33: PASS"
