type
  ReportState = object
    accepted: int
    rejected: int
    messages: seq[string]

proc recordAccepted(state: var ReportState; name: string) =
  inc state.accepted
  state.messages.add "accepted " & name

proc recordRejected(state: var ReportState; name: string) =
  inc state.rejected
  state.messages.add "rejected " & name

proc buildReport(names: openArray[string]): seq[string] =
  var state: ReportState
  for name in names:
    if name.len > 0:
      state.recordAccepted(name)
    else:
      state.recordRejected("<empty>")

  result = state.messages
  result.add "accepted " & $state.accepted
  result.add "rejected " & $state.rejected

proc countNonEmpty(names: openArray[string]): int =
  for name in names:
    if name.len > 0:
      inc result

doAssert countNonEmpty(["alpha", "", "beta"]) == 2
doAssert buildReport(["alpha", "", "beta"]) == @[
  "accepted alpha",
  "rejected <empty>",
  "accepted beta",
  "accepted 2",
  "rejected 1"
]

echo "ref_orchestration_pattern: PASS"
