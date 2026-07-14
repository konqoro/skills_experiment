import std/assertions

type
  Completion[T] = object
    value: T
    finished: bool

  OutputMode {.pure.} = enum
    Compact
    Detailed

proc completeImpl[T, U](target: var Completion[T]; value: U;
    hasValue: static[bool]) =
  when hasValue:
    target.value = value
  target.finished = true

proc complete[T](target: var Completion[T]; value: T) =
  completeImpl(target, value, true)

proc complete(target: var Completion[void]) =
  completeImpl(target, (), false)

proc label(value: int; mode: static[OutputMode]): string =
  when mode == OutputMode.Compact:
    $value
  else:
    "value: " & $value

var number: Completion[int]
number.complete(42)
doAssert number.finished
doAssert number.value == 42

var empty: Completion[void]
empty.complete()
doAssert empty.finished

doAssert label(7, OutputMode.Compact) == "7"
doAssert label(7, OutputMode.Detailed) == "value: 7"

echo "C11: PASS"
