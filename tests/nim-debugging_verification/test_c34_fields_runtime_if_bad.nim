type
  Config = object
    name: string
    retries: int
    verbose: bool

# Expected compile error: the runtime `if` does not prevent `inc value` from
# being checked for the string and bool fields.
proc incrementInts(c: var Config) =
  for value in c.fields:
    if value is int:
      inc value

var c = Config(name: "db", retries: 3, verbose: true)
c.incrementInts()
