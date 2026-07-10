# Test C15: raw bindings should use typed integer aliases + const, not Nim enum
# Demonstrate that typed alias + const works
type LibMode = cint
const
  LIB_MODE_A = LibMode(0)
  LIB_MODE_B = LibMode(2)
  LIB_MODE_C = LibMode(3)

var m: LibMode = LIB_MODE_A
doAssert m == LibMode(0)
m = LIB_MODE_B
doAssert m == LibMode(2)

echo "C15: PASS"
