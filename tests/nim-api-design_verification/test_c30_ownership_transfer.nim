proc main() =
  block:
    var source = "checked"
    let destination = ensureMove(source)
    doAssert destination == "checked"

  block:
    var source = "unchecked"
    let destination = move(source)
    doAssert destination == "unchecked"
    doAssert source.len == 0

  echo "C30: PASS"

main()
