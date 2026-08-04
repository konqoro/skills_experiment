# Test: C51 - openArray accepts arrays (any index type) and seqs, seq params
# reject arrays, and forwarding an openArray to a seq-taking callee copies via
# @items even when the caller already held a seq. (C50 is a design guideline;
# the compiler facts it relies on are verified here.)
type
  Dir = enum north, east, south, west

  Msg = object
    id: int

var copies = 0
proc `=copy`(dest: var Msg; src: Msg) =
  copies.inc
  dest.id = src.id

proc takesOA(x: openArray[Msg]): int = x.len
proc takesSeq(x: seq[Msg]): int = x.len

# seq parameters reject arrays; openArray accepts arrays, seqs, and literals.
doAssert not compiles(takesSeq([Msg(id: 1), Msg(id: 2)]))
doAssert compiles(takesOA([Msg(id: 1), Msg(id: 2)]))
var dirIdx: array[Dir, Msg]
dirIdx = [Msg(id: 1), Msg(id: 2), Msg(id: 3), Msg(id: 4)]
doAssert compiles(takesOA(dirIdx))           # enum-indexed array
doAssert compiles(takesOA(@[Msg(id: 1)]))
doAssert compiles(takesSeq(@[Msg(id: 1)]))

# Forwarding an openArray to a seq-taking callee copies the elements with @x,
# even when the caller already held a seq; a seq passes through with no copies.
proc consumeSeq(s: seq[Msg]) = discard

proc fwdOpenArray(x: openArray[Msg]) =
  consumeSeq(@x)

proc fwdSeq(x: seq[Msg]) =
  consumeSeq(x)

let sq = @[Msg(id: 1), Msg(id: 2)]

copies = 0
fwdOpenArray(sq)
doAssert copies == 2, "openArray forward copies: " & $copies

copies = 0
fwdSeq(sq)
doAssert copies == 0, "seq forward copies: " & $copies

echo "C50 C51: PASS"
