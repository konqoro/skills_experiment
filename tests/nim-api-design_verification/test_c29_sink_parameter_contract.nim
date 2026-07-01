var copyCount = 0

type
  Token = object
    value: ptr int

proc `=destroy`(token: Token) =
  if token.value != nil:
    dealloc(token.value)

proc `=wasMoved`(token: var Token) =
  token.value = nil

proc `=copy`(dest: var Token; src: Token) =
  inc copyCount
  `=destroy`(dest)
  `=wasMoved`(dest)
  if src.value != nil:
    dest.value = create(int)
    dest.value[] = src.value[]

proc newToken(value: int): Token =
  result.value = create(int)
  result.value[] = value

proc take(token: sink Token): int =
  token.value[]

proc testSinkCalls() =
  var retained = newToken(7)
  doAssert take(retained) == 7
  doAssert retained.value[] == 7
  doAssert copyCount == 1

  let copiesBeforeMoves = copyCount
  doAssert take(newToken(8)) == 8
  doAssert copyCount == copiesBeforeMoves

  var lastUse = newToken(9)
  let observed = take(lastUse)
  doAssert observed == 9
  doAssert copyCount == copiesBeforeMoves

testSinkCalls()

echo "C29: PASS"
