import std/assertions

type
  ParentError = object of CatchableError
  ChildError = object of ParentError

proc handleParentFirst(): string =
  try:
    raise newException(ChildError, "child")
  except ParentError:
    result = "parent"
  except ChildError:
    result = "child"

proc handleChildFirst(): string =
  try:
    raise newException(ChildError, "child")
  except ChildError:
    result = "child"
  except ParentError:
    result = "parent"

block exception_handlers_use_source_order:
  doAssert handleParentFirst() == "parent"
  doAssert handleChildFirst() == "child"

echo "C35: PASS"
