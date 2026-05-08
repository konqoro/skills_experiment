proc main() =
  # C09: exception triage in fuzz harness — which exception types mask Defect bugs?
  block specific_catch:
    var caught = false
    try:
      raise newException(ValueError, "bad input")
    except ValueError:
      caught = true
    doAssert caught

  block catchable_does_not_catch_defect:
    var catchableCaught = false
    var defectCaught = false
    try:
      try:
        raise newException(IndexDefect, "oob")
      except CatchableError:
        catchableCaught = true
    except IndexDefect:
      defectCaught = true
    doAssert not catchableCaught
    doAssert defectCaught

  block exception_does_catch_defect:
    var caught = false
    try:
      raise newException(IndexDefect, "oob")
    except Exception:
      caught = true
    doAssert caught

  echo "C09: PASS"

main()
