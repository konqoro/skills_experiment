type
  Config = object
    name: string
    retries: int
    verbose: bool

proc describe(c: Config): string =
  for name, value in c.fieldPairs:
    when name == "name":
      result.add value
    elif value is int:
      result.add ":" & $value
    elif value is bool:
      result.add ":" & $value

proc countStringFields(c: Config): int =
  for value in c.fields:
    when value is string:
      inc result

let c = Config(name: "db", retries: 3, verbose: true)
doAssert describe(c) == "db:3:true"
doAssert countStringFields(c) == 1

echo "C33: PASS"
