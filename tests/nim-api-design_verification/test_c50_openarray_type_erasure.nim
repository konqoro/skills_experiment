# Test: C50 - openArray erases the container type. A proc that must return or
# forward a container needs the concrete type: openArray is not a valid return
# type, cannot be assigned to a seq result, and forwarding it to a seq-taking
# callee forces a whole-seq copy (@s) even when the caller already held a seq.
type
  Msg = object
    id: int

var copies = 0
proc `=copy`(dest: var Msg; src: Msg) =
  copies.inc
  dest.id = src.id

# openArray is not a valid return type, so a proc that returns a container
# must name the concrete type (seq[T] or array[N, T]).
doAssert not compiles(proc (s: openArray[Msg]): openArray[Msg] = s)
doAssert compiles(proc (s: seq[Msg]): seq[Msg] = s)

# An openArray parameter cannot be assigned to a seq result; the callee must
# materialize a copy with @s. A seq parameter assigns directly.
doAssert not compiles(
  proc (s: openArray[Msg]): seq[Msg] =
    result = s)
doAssert compiles(
  proc (s: seq[Msg]): seq[Msg] =
    result = s)
doAssert compiles(
  proc (s: openArray[Msg]): seq[Msg] =
    result = @s)

# Immutable pass-through: openArray-typed data forwarded to a seq-taking
# callee needs a whole-seq copy (@s) even when the caller already held a seq;
# a seq parameter passes straight through with no copies.
proc consume(s: seq[Msg]) = discard

proc fwdOpenArray(s: openArray[Msg]) =
  let s2 = @s
  consume(s2)

proc fwdSeq(s: seq[Msg]) =
  consume(s)

let sq = @[Msg(id: 1), Msg(id: 2)]

copies = 0
fwdOpenArray(sq)
doAssert copies == 2, "openArray immutable forward copies: " & $copies

copies = 0
fwdSeq(sq)
doAssert copies == 0, "seq forward copies: " & $copies

echo "C50: PASS"
