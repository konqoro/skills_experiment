# C55 negative: ensureMove prevents use-after-move.
# After ensureMove(a), the source 'a' is compiler-dead — any use
# is a compile error. Contrast with move where the source stays alive.
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
  var a = newFd(5)
  var b = ensureMove(a)
  echo compute(a)  # a is dead — this must fail to compile

main()
