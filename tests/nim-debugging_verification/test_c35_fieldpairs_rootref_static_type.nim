type
  Base = ref object of RootObj
    baseValue: int
  Derived = ref object of Base
    derivedValue: string

proc fieldNames(value: Base): seq[string] =
  for name, field in value[].fieldPairs:
    result.add name

proc fieldNames(value: Derived): seq[string] =
  for name, field in value[].fieldPairs:
    result.add name

proc countFields(value: RootRef): int =
  for name, field in value[].fieldPairs:
    inc result

let derived = Derived(baseValue: 1, derivedValue: "two")
let base: Base = derived
let root: RootRef = derived

let derivedNames = fieldNames(derived)
doAssert derivedNames.len == 2
doAssert "baseValue" in derivedNames
doAssert "derivedValue" in derivedNames
doAssert fieldNames(base) == @["baseValue"]
doAssert countFields(root) == 0

echo "C35: PASS"
