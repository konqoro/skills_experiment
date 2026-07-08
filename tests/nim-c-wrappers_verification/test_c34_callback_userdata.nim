# Test C34: pass Nim closure state through C userdata via rawProc/rawEnv.
# A Nim closure carries both a function pointer and an environment pointer.
# rawProc extracts the function pointer; rawEnv extracts the environment.
# The environment must be GC_ref'd so it survives after the closure itself
# is destroyed. The raw proc expects the env pointer as its LAST argument.
# The C callback signature must match: real arguments first, then userdata last.

type
  CallbackState = ref object
    total: int

  # C callback type: code first, userdata last (matches rawProc calling convention)
  CallbackFn = proc(code: cint; userdata: pointer) {.cdecl.}
  CallbackRegistration = object
    fn: CallbackFn
    userdata: pointer

proc makeCallback(state: CallbackState): proc(code: cint) {.closure.} =
  result = proc(code: cint) =
    state.total += int(code)

proc registerCallback(cb: proc(code: cint) {.closure.}): CallbackRegistration =
  let rp = rawProc(cb)
  let re = rawEnv(cb)
  if not re.isNil:
    GC_ref(cast[RootRef](re))
    result = CallbackRegistration(fn: cast[CallbackFn](rp), userdata: re)
  else:
    result = CallbackRegistration(fn: cast[CallbackFn](rp), userdata: nil)

proc unregisterCallback(reg: CallbackRegistration) =
  if not reg.userdata.isNil:
    GC_unref(cast[RootRef](reg.userdata))

let state = CallbackState(total: 0)
var reg: CallbackRegistration

# Register inside a block so the closure goes out of scope.
# The callback must still work because GC_ref keeps the env alive.
block:
  let cb = makeCallback(state)
  reg = registerCallback(cb)

GC_fullCollect()

# Simulate C calling back: code first, userdata last
reg.fn(cint(7), reg.userdata)
reg.fn(cint(5), reg.userdata)
unregisterCallback(reg)

doAssert state.total == 12

echo "C34: PASS"
