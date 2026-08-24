type
  Config = object
    name: string
    retries: int
    verbose: bool

# Expected compile error: the runtime `if` does not prevent `inc value` from
# being checked for the string and bool fields.
proc incrementRetries(c: var Config) =
  for name, value in c.fieldPairs:
    if name == "retries":
      inc value

var c = Config(name: "db", retries: 3, verbose: true)
c.incrementRetries()
