## Test C28: C macro mapping
## numeric → const; function-like → template; inline proc when args evaluate once

# --- numeric C macro → Nim const ---
# C: #define MAX_CHANNELS 16
const MAX_CHANNELS = 16
static: doAssert MAX_CHANNELS == 16

# --- function-like C macro → Nim template (default, type-generic like the C macro) ---
# C: #define MAX(a, b) ((a) > (b) ? (a) : (b))
template cmax(a, b: untyped): untyped =
  if a > b: a else: b

doAssert cmax(3, 7) == 7
doAssert cmax(2.5, 1.0) == 2.5
doAssert cmax("z", "a") == "z"

# --- inline proc when arguments should evaluate once ---
# C: #define SQR(x) ((x)*(x))
# A template multi-evaluates x (appears twice in body); inline proc evaluates once.
var evalCount = 0
proc counted(v: int): int =
  evalCount += 1
  v

template sqrTmpl(x: untyped): untyped = x * x
proc sqrProc(x: int): int {.inline.} = x * x

# template: x substituted twice → evaluated twice
evalCount = 0
doAssert sqrTmpl(counted(5)) == 25
doAssert evalCount == 2

# inline proc: argument bound once → evaluated once
evalCount = 0
doAssert sqrProc(counted(5)) == 25
doAssert evalCount == 1

echo "C28: PASS"
