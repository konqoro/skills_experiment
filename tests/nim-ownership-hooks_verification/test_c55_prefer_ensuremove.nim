# C55: Prefer ensureMove over move.
# move leaves the source "alive" to the compiler. If the source is used
# after move, it reads the moved-from (default) value — wrong computation.
# ensureMove makes the source compiler-dead: any use is a compile error.
type
  Fd = object
    fd: int

proc `=destroy`*(x: Fd) =
  if x.fd != 0: discard

proc `=wasMoved`*(x: var Fd) = x.fd = 0
proc `=copy`*(dest: var Fd; src: Fd) {.error.}
proc `=dup`*(src: Fd): Fd {.error.}

proc newFd(f: int): Fd = Fd(fd: f)
proc compute(f: Fd): int = f.fd * 2

proc main() =
  # ensureMove: safe — source is dead, no use possible
  block:
    var a = newFd(5)
    var b = ensureMove(a)
    doAssert b.fd == 5
    doAssert compute(b) == 10
    # a cannot be used here — compile error if attempted

  # move: source is still alive to compiler
  # The moved-from value (fd=0) can be accidentally used
  block:
    var a = newFd(5)
    var b = move(a)
    doAssert a.fd == 0     # wasMoved reset it
    doAssert b.fd == 5
    # compute(a) would return 0 — wrong answer, no compile error

  echo "C55: PASS"

main()
