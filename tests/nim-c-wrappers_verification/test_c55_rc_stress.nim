## Stress-tests the reference-count convention used by rc_resource.md.

var
  rawAllocations = 0
  rawFrees = 0
  counterAllocations = 0
  counterFrees = 0

type
  RawAsset = object
    value: int

proc libLoad(): ptr RawAsset =
  inc rawAllocations
  result = cast[ptr RawAsset](alloc0(sizeof(RawAsset)))
  result.value = 42

proc libFreeAsset(raw: ptr RawAsset) =
  inc rawFrees
  dealloc(raw)

type
  Asset = object
    raw: ptr RawAsset
    rc: ptr int

proc `=destroy`(asset: Asset) =
  if asset.raw != nil:
    if asset.rc[] == 0:
      libFreeAsset(asset.raw)
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
  result.raw = src.raw
  result.rc = src.rc
  if result.raw != nil:
    inc result.rc[]

proc loadAsset(): Asset =
  inc counterAllocations
  Asset(
    raw: libLoad(),
    rc: cast[ptr int](alloc0(sizeof(int))))

proc share(asset: Asset): Asset =
  asset

proc exercise() =
  var first = loadAsset()
  doAssert first.rc[] == 0

  var second = share(first)
  doAssert first.rc[] == 1

  var third = share(second)
  doAssert first.rc[] == 2

  second = share(third)
  doAssert first.rc[] == 2

  second = second
  doAssert first.rc[] == 2

  var moved = ensureMove(first)
  doAssert moved.raw.value == 42
  doAssert moved.rc[] == 2

exercise()

doAssert rawAllocations == 1
doAssert rawFrees == 1
doAssert counterAllocations == 1
doAssert counterFrees == 1

echo "C55: PASS"
