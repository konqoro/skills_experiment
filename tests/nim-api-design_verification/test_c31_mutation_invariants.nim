type
  Registry = object
    names: seq[string]
    cachedLen: int

proc names(registry: var Registry): var seq[string] =
  registry.names

proc addName(registry: var Registry; name: string) =
  if name.len == 0:
    raise newException(ValueError, "name is empty")
  if name in registry.names:
    raise newException(ValueError, "duplicate name")
  registry.names.add name
  registry.cachedLen = registry.names.len

var exposed: Registry
exposed.addName("alpha")
exposed.names.add ""
doAssert exposed.names.len != exposed.cachedLen
doAssert "" in exposed.names

var guarded: Registry
guarded.addName("alpha")

var rejectedEmpty = false
try:
  guarded.addName("")
except ValueError:
  rejectedEmpty = true

var rejectedDuplicate = false
try:
  guarded.addName("alpha")
except ValueError:
  rejectedDuplicate = true

doAssert rejectedEmpty
doAssert rejectedDuplicate
doAssert guarded.names == @["alpha"]
doAssert guarded.cachedLen == 1

echo "C31: PASS"
