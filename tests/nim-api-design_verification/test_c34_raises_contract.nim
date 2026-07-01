proc noRaise(value: int): int {.raises: [].} =
  value + 1

proc broadRaise(kind: bool) {.raises: [Exception].} =
  if kind:
    raise newException(ValueError, "value")
  raise newException(IOError, "io")

doAssert noRaise(2) == 3

static:
  doAssert not compiles(
    block:
      proc invalidNoRaise() {.raises: [].} =
        broadRaise(true)
  )
  doAssert compiles(
    block:
      proc broadContract(kind: bool) {.raises: [Exception].} =
        broadRaise(kind)
  )

echo "C34: PASS"
