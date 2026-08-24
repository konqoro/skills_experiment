var destroyed = 0

type Token* = object
  data: ptr int

proc `=destroy`(x: Token) =
  if x.data != nil:
    inc destroyed
    dealloc(x.data)

proc `=wasMoved`(x: var Token) =
  x.data = nil

proc `=copy`(dst: var Token; src: Token) {.error.}
proc `=dup`(src: Token): Token {.error.}

proc makeToken*(): Token =
  result.data = create(int)
  result.data[] = 42

proc value*(x: Token): int =
  if x.data == nil: -1 else: x.data[]

proc destroyedCount*(): int = destroyed
