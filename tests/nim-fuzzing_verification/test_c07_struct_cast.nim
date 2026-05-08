proc main() =
  # C07: Cast a byte buffer to a C struct after bounds check
  type
    MyHeader {.packed.} = object
      magic: uint32
      version: uint16
      flags: uint16

  block struct_cast:
    var header = MyHeader(magic: 0xDEADBEEF'u32, version: 1'u16, flags: 0x8000'u16)
    let p = cast[ptr MyHeader](addr header)
    let raw = cast[ptr UncheckedArray[byte]](p)
    if sizeof(MyHeader) <= 8:
      let parsed = cast[ptr MyHeader](raw)
      doAssert parsed.magic == 0xDEADBEEF'u32
      doAssert parsed.version == 1'u16
      doAssert parsed.flags == 0x8000'u16

  block bounds_fail:
    let len = 2
    doAssert len < sizeof(MyHeader)

  echo "C07: PASS"

main()
