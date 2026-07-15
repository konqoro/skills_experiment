import std/assertions

type
  Handle = ref object
  Status = enum
    success, failure

proc createWithNil(fail: bool): Handle =
  if not fail:
    result = Handle()

proc acquireFromNil(fail: bool): Handle =
  result = createWithNil(fail)
  if result.isNil:
    raise newException(IOError, "resource creation failed")

proc createWithStatus(fail: bool): tuple[status: Status, handle: Handle] =
  if fail:
    result = (failure, nil)
  else:
    result = (success, Handle())

proc acquireFromStatus(fail: bool): Handle =
  let created = createWithStatus(fail)
  if created.status == failure:
    raise newException(IOError, "resource creation failed")
  result = created.handle

block use_the_documented_failure_channel:
  doAssert not acquireFromNil(false).isNil
  doAssertRaises IOError:
    discard acquireFromNil(true)

  doAssert not acquireFromStatus(false).isNil
  doAssertRaises IOError:
    discard acquireFromStatus(true)

echo "C16: PASS"
