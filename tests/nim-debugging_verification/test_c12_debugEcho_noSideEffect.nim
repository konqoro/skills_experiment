import std/assertions

proc add(a, b: int): int {.noSideEffect.} =
  debugEcho "a=", a, " b=", b
  return a + b

proc main() =
  let r = add(3, 4)
  doAssert r == 7
  echo "C12: PASS"

main()
