import std/assertions

type Box[T] = object
  value: T

func wrap[T](x: T): Box[T] =
  Box[T](value: x)

func castValue[T, U](x: Box[T]): U =
  U(x.value)

func plusAs[T, U](x: Box[T]; y: T): U =
  U(x.value + y)

block generic_params_in_ufcs:
  let box = 3.wrap()

  doAssert wrap[int](3).value == 3
  doAssert 3.wrap[:int]().value == 3
  doAssert not compiles(3.wrap[int]())

  doAssert castValue[int, float](box) == 3.0
  doAssert box.castValue[:int, float]() == 3.0

  doAssert plusAs[int, float](box, 4) == 7.0
  doAssert box.plusAs[:int, float](4) == 7.0

echo "C24: PASS"
