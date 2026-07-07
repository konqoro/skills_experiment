import std/assertions

type
  GoodVersion = object
    major, minor: int

  BadVersion = object
    major, minor: int

func `==`(a, b: GoodVersion): bool =
  a.major == b.major and a.minor == b.minor

func `<`(a, b: GoodVersion): bool =
  (a.major, a.minor) < (b.major, b.minor)

func `<=`(a, b: GoodVersion): bool =
  a < b or a == b

func `==`(a, b: BadVersion): bool =
  a.major == b.major and a.minor == b.minor

func `<`(a, b: BadVersion): bool =
  (a.major, a.minor) < (b.major, b.minor)

func `<=`(a, b: BadVersion): bool =
  a < b or a == b

func `!=`(a, b: BadVersion): bool = false
func `>`(a, b: BadVersion): bool = false
func `>=`(a, b: BadVersion): bool = false

block derived_comparison_operators:
  let v10 = GoodVersion(major: 1, minor: 0)
  let v11 = GoodVersion(major: 1, minor: 1)
  let v20 = GoodVersion(major: 2, minor: 0)

  doAssert v10 != v11
  doAssert v20 > v11
  doAssert v20 >= v20
  doAssert v11 >= v10
  doAssert not (v10 > v11)
  doAssert not (v10 >= v11)

block direct_definitions_override_derivation:
  let v10 = BadVersion(major: 1, minor: 0)
  let v11 = BadVersion(major: 1, minor: 1)

  doAssert v10 == v10
  doAssert v10 < v11
  doAssert v10 <= v11
  doAssert not (v10 != v11)
  doAssert not (v11 > v10)
  doAssert not (v11 >= v10)

echo "C35: PASS"
