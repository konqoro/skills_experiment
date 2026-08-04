# Test: C43 - accessors may share the field's name; there is no collision.
# Outside the module, `x.host`/`x.host = v` route to the accessors when the
# field is private; inside the module, dot access reaches the field. A visible
# field bypasses the accessors.
import std/assertions
import test_c43_accessor_field_name_src/accessors

var s = Socket()
s.host = 34                    # outside the module: calls the setter
doAssert s.host == 34          # outside the module: calls the getter
doAssert socketSetCalls == 1, "setter should run once, got " & $socketSetCalls
doAssert socketGetCalls == 1, "getter should run once, got " & $socketGetCalls

socketSetCalls = 0
socketGetCalls = 0
s.fieldWrite(7)
doAssert s.fieldRead() == 7    # inside the module: plain field access
doAssert socketSetCalls == 0 and socketGetCalls == 0,
  "inside the module, dot access must reach the field, not the accessors"

var o = Open()
o.val = 5                      # visible field: assignment, setter bypassed
doAssert o.val == 5
doAssert openSetCalls == 0, "visible field must bypass the setter, got " & $openSetCalls

echo "C43: PASS"
