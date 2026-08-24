# C53 companion: without =dup {.error.}, explicit =dup silently returns a
# moved-from value even though =copy is forbidden.

type Handle = object
  data: ptr int

proc `=destroy`(x: Handle) =
  if x.data != nil:
    dealloc(x.data)

proc `=wasMoved`(x: var Handle) =
  x.data = nil

proc `=copy`(dst: var Handle; src: Handle) {.error.}

proc newHandle(value: int): Handle =
  result.data = create(int)
  result.data[] = value

proc main =
  var source = newHandle(42)
  var duplicate = `=dup`(source)

  doAssert source.data != nil
  doAssert source.data[] == 42
  doAssert duplicate.data == nil

main()
echo "C53 omitted dup: PASS"
