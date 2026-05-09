import std/[os, osproc, strutils, sequtils]

proc main() =
  let tmpdir = getTempDir()

  block ref_proto_harness_compiles:
    let harness = tmpdir / "ref_proto_harness.nim"
    writeFile(harness, """
import std/[httpcore, parseutils, strutils, uri]

const
  localMaxBody = 8 * 1024 * 1024
  localMaxLine = 8 * 1024

type ParsedRequest = object
  reqMethod: HttpMethod
  headers: HttpHeaders
  protocol: tuple[orig: string, major, minor: int]
  url: Uri
  body: string

proc parseProtocolOriginal(protocol: string): tuple[orig: string, major, minor: int] =
  result = default(tuple[orig: string, major, minor: int])
  var i = protocol.skipIgnoreCase("HTTP/")
  if i != 5:
    raise newException(ValueError, "Invalid request protocol. Got: " & protocol)
  result.orig = protocol
  i.inc protocol.parseSaturatedNatural(result.major, i)
  i.inc
  i.inc protocol.parseSaturatedNatural(result.minor, i)

proc parseMethod(part: string): HttpMethod =
  case part
  of "GET": HttpGet
  of "POST": HttpPost
  of "HEAD": HttpHead
  of "PUT": HttpPut
  of "DELETE": HttpDelete
  of "PATCH": HttpPatch
  of "OPTIONS": HttpOptions
  of "CONNECT": HttpConnect
  of "TRACE": HttpTrace
  else:
    raise newException(ValueError, "unknown method")

proc nextLine(input: string, pos: var int): string =
  if pos >= input.len: return ""
  let start = pos
  while pos < input.len and input[pos] notin {'\r', '\n'}:
    inc pos
  result = input[start ..< pos]
  if pos < input.len and input[pos] == '\r': inc pos
  if pos < input.len and input[pos] == '\n': inc pos

proc parseFullRequestOriginal(input: string): ParsedRequest =
  result = default(ParsedRequest)
  var pos = 0
  let requestLine = nextLine(input, pos)
  if requestLine.len == 0:
    raise newException(ValueError, "empty request line")
  let parts = requestLine.split(' ')
  if parts.len < 3:
    raise newException(ValueError, "malformed request line")
  result.reqMethod = parseMethod(parts[0])
  result.url = parseUri(parts[1])
  result.protocol = parseProtocolOriginal(parts[2])

proc testOneInput(data: ptr UncheckedArray[byte], len: int): cint {.
    exportc: "LLVMFuzzerTestOneInput", raises: [].} =
  result = 0
  if len == 0: return
  let inputLen = int(len)
  var input = newString(inputLen)
  copyMem(addr input[0], data, inputLen)
  try:
    discard parseFullRequestOriginal(input)
  except ValueError:
    discard

proc initialize(): cint {.exportc: "LLVMFuzzerInitialize".} =
  {.emit: "N_CDECL(void, NimMain)(void); NimMain();".}
""")
    let (buildOut, exitCode) = execCmdEx("nim c --hints:off " & harness & " 2>&1")
    if exitCode == 0:
      echo "REF_PROTO_HARNESS: PASS"
    else:
      echo "REF_PROTO_HARNESS: FAIL: " & buildOut.strip
    removeFile(harness)

  block ref_proto_seeds_valid:
    let corpusDir = tmpdir / "ref_proto_corpus"
    createDir(corpusDir)
    let seeds = [
      ("seed_get_http11", "GET / HTTP/1.1\r\nHost: localhost\r\n\r\n"),
      ("seed_post_content_length", "POST /submit HTTP/1.1\r\nHost: localhost\r\nContent-Length: 5\r\n\r\nhello"),
      ("seed_post_chunked", "POST /data HTTP/1.1\r\nHost: localhost\r\nTransfer-Encoding: chunked\r\n\r\n5\r\nhello\r\n0\r\n\r\n"),
    ]
    var allOk = true
    for (name, content) in seeds:
      writeFile(corpusDir / name, content)
      if not fileExists(corpusDir / name):
        allOk = false
    let seedCount = toSeq(walkFiles(corpusDir / "*")).len
    if allOk and seedCount == 3:
      echo "REF_PROTO_SEEDS: PASS"
    else:
      echo "REF_PROTO_SEEDS: FAIL"
    removeDir(corpusDir)

  block ref_proto_error_triage:
    let harness = tmpdir / "ref_proto_triage_test.nim"
    writeFile(harness, """
import std/strutils

proc parse(input: string): int =
  if input.len == 0:
    raise newException(ValueError, "empty")
  result = parseInt(input)

block:
  try:
    discard parse("")
    echo "UNEXPECTED: ValueError not raised"
  except ValueError:
    echo "OK: ValueError caught as expected"
  except:
    echo "UNEXPECTED: caught by bare except"
""")
    let buildBin = tmpdir / "ref_proto_triage_bin"
    let (_, buildExit) = execCmdEx(
      "nim c --hints:off -o:" & buildBin & " " & harness & " 2>&1")
    if buildExit == 0:
      let (runOut, runExit) = execCmdEx(buildBin & " 2>&1")
      if runExit == 0 and runOut.contains("OK") and
         not runOut.contains("UNEXPECTED"):
        echo "REF_PROTO_TRIAGE: PASS"
      else:
        echo "REF_PROTO_TRIAGE: FAIL: " & runOut.strip
    else:
      echo "REF_PROTO_TRIAGE: FAIL: build failed"
    for f in [harness, buildBin]:
      if fileExists(f): removeFile(f)

main()
