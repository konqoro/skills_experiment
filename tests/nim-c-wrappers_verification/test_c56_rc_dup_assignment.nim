## Probes the book-style `result = src` plus explicit increment in `=dup`.

var
  rawFrees = 0
  counterFrees = 0

type
  RawAsset = object
  Asset = object
    raw: ptr RawAsset
    rc: ptr int

proc `=destroy`(asset: Asset) =
  if asset.raw != nil:
    if asset.rc[] == 0:
      inc rawFrees
      dealloc(asset.raw)
      inc counterFrees
      dealloc(asset.rc)
    else:
      dec asset.rc[]

proc `=wasMoved`(asset: var Asset) =
  asset.raw = nil
  asset.rc = nil

proc `=sink`(dest: var Asset; src: Asset) =
  `=destroy`(dest)
  dest.raw = src.raw
  dest.rc = src.rc

proc `=copy`(dest: var Asset; src: Asset) =
  if src.raw != nil:
    inc src.rc[]
  `=destroy`(dest)
  dest.raw = src.raw
  dest.rc = src.rc

proc `=dup`(src: Asset): Asset =
  result = src
  if result.raw != nil:
    inc result.rc[]

proc initAsset(): Asset =
  Asset(
    raw: cast[ptr RawAsset](alloc0(sizeof(RawAsset))),
    rc: cast[ptr int](alloc0(sizeof(int))))

proc exercise() =
  var first = initAsset()
  var second = `=dup`(first)
  doAssert first.raw == second.raw
  doAssert first.rc[] == 2

  # Two live owners require a count of one. Normalize the deliberately
  # over-incremented probe so teardown can still verify balanced frees.
  dec first.rc[]

exercise()

doAssert rawFrees == 1
doAssert counterFrees == 1

echo "C56: PASS"
