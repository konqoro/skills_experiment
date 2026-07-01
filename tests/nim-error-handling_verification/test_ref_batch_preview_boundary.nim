# Test: batch_preview_boundary.md reference compiles and works

type
  PreviewItem = object
    path: string
    success: bool
    previewId: string
    errorMsg: string

  BatchSummary = object
    okCount: int
    failCount: int
    items: seq[PreviewItem]

proc fakeReadPages(path: string): seq[string] =
  if path.len == 0:
    raise newException(IOError, "path is empty")
  case path
  of "missing":
    raise newException(IOError, "document missing")
  of "blank":
    result = @[""]
  else:
    result = @[path & "-page-1", path & "-page-2"]

proc fakeUpload(payload: seq[byte]): string =
  if payload.len == 0:
    raise newException(OSError, "upload payload empty")
  result = "preview-" & $payload.len

proc fakeAuditWrite(auditPath: string; line: string) =
  if auditPath == "audit-fail":
    raise newException(OSError, "audit write failed")

proc buildPreviewPayload(pages: seq[string]; pageIndex: int): seq[byte] =
  if pageIndex >= pages.len:
    raise newException(ValueError, "page index out of bounds")
  let page = pages[pageIndex]
  if page.len == 0:
    raise newException(IOError, "selected page was empty")
  result = @(page.toOpenArrayByte(0, page.high))

proc processOne(path: string; pageIndex: int): string =
  let pages = fakeReadPages(path)
  let payload = buildPreviewPayload(pages, pageIndex)
  result = fakeUpload(payload)

proc writeAuditLine(auditPath: string; line: string) =
  try:
    fakeAuditWrite(auditPath, line)
  except OSError:
    raise newException(IOError, "audit write failed for " & auditPath & ": " &
        getCurrentExceptionMsg())

proc runBatch(paths: seq[string]; pageNo: Positive; auditPath: string): BatchSummary =
  let pageIndex = pageNo.int - 1
  result.items = @[]
  for path in paths:
    try:
      let previewId = processOne(path, pageIndex)
      result.items.add PreviewItem(
        path: path,
        success: true,
        previewId: previewId,
        errorMsg: ""
      )
      inc result.okCount
    except CatchableError:
      let msg = getCurrentExceptionMsg()
      writeAuditLine(auditPath, path & ": " & msg)
      result.items.add PreviewItem(
        path: path,
        success: false,
        previewId: "",
        errorMsg: msg
      )
      inc result.failCount

proc main =
  # Test 1: successful batch
  let s1 = runBatch(@["doc1", "doc2"], Positive(1), "audit.log")
  doAssert s1.okCount == 2
  doAssert s1.failCount == 0
  doAssert s1.items[0].success
  doAssert s1.items[0].previewId == "preview-11"  # "doc1-page-1" = 11 bytes
  doAssert s1.items[1].success

  # Test 2: mixed success/failure
  let s2 = runBatch(@["ok", "missing", "blank"], Positive(1), "audit.log")
  doAssert s2.okCount == 1
  doAssert s2.failCount == 2
  doAssert s2.items[1].errorMsg == "document missing"
  doAssert s2.items[2].errorMsg == "selected page was empty"

  # Test 3: page index out of bounds
  let s3 = runBatch(@["doc"], Positive(5), "audit.log")
  doAssert s3.failCount == 1
  doAssert s3.items[0].errorMsg == "page index out of bounds"

  # Test 4: audit failure aborts the batch with added context
  var auditFailed = false
  try:
    discard runBatch(@["missing"], Positive(1), "audit-fail")
  except IOError:
    auditFailed = true
    doAssert getCurrentExceptionMsg() ==
        "audit write failed for audit-fail: audit write failed"
  doAssert auditFailed

main()
echo "ref_batch_preview_boundary: PASS"
