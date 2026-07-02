proc main() =
  # C07: Copy a byte buffer into a local fixed-layout value
  type
    MyHeader = object
      magic: uint32
      version: uint16
      flags: uint16

  block fixed_layout_copy:
    var header = MyHeader(magic: 0xDEADBEEF'u32, version: 1'u16, flags: 0x8000'u16)
    var storage: array[sizeof(MyHeader) + 1, byte]
    copyMem(addr storage[1], addr header, sizeof(header))
    let data = cast[ptr UncheckedArray[byte]](addr storage[1])
    var parsed: MyHeader
    copyMem(addr parsed, data, sizeof(parsed))
    doAssert parsed.magic == 0xDEADBEEF'u32
    doAssert parsed.version == 1'u16
    doAssert parsed.flags == 0x8000'u16

  block bounds_fail:
    let len = 2
    doAssert len < sizeof(MyHeader)

  echo "C07: PASS"

main()
