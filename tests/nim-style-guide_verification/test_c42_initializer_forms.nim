# Test: C42 - `T()` construction works only for object types. Arrays need
# `arrayWith(value, N)` or `arrayWithDefault[T](N)`, anonymous tuples need a
# literal, strings and seqs use `""` and `@[]`, and `default(T)` is the
# universal catch-all, including inside generics.
type
  DistInt = distinct int
  Named = tuple[id: int, name: string]

proc `==`(a, b: DistInt): bool {.borrow.}

proc namedLit(): Named = (id: 1, name: "x")

proc arrayWithInit(): array[3, int] = arrayWith(0, 3)
proc arrayDefaultInit(): array[3, int] = arrayWithDefault[int](3)
proc tupleLit(): (int, string) = (0, "")
proc distConv(): DistInt = DistInt(0)
proc distDefault(): DistInt = default(DistInt)
proc strLit(): string = ""
proc seqLit(): seq[int] = @[]

proc defaultArray(): array[3, int] = default(array[3, int])
proc defaultTuple(): (int, string) = default((int, string))
proc defaultStr(): string = default(string)
proc defaultSeq(): seq[int] = default(seq[int])

proc genericDefault[T](): T = default(T)

# `T()` is rejected for arrays, strings, seqs, and tuple type aliases.
doAssert not compiles(array[3, int]())
doAssert not compiles(string())
doAssert not compiles(seq[int]())
doAssert not compiles(Named(id: 1, name: "x"))

# Each type has its own working initializer form.
doAssert arrayWithInit() == [0, 0, 0]
doAssert arrayDefaultInit() == [0, 0, 0]
doAssert tupleLit() == (0, "")
doAssert namedLit() == (id: 1, name: "x")
doAssert distConv() == DistInt(0)
doAssert distDefault() == DistInt(0)
doAssert strLit() == ""
doAssert seqLit() == @[]

# default(T) is the universal fallback, including in generics.
doAssert defaultArray() == [0, 0, 0]
doAssert defaultTuple() == (0, "")
doAssert defaultStr() == ""
doAssert defaultSeq() == @[]
doAssert genericDefault[int]() == 0
doAssert genericDefault[string]() == ""

echo "C42: PASS"
