import std/[strutils, parseutils]

type
  Header* = object
    name*: string
    value*: string

  Request* = object
    verb*: string
    path*: string
    headers*: seq[Header]
    body*: string

  Route* = object
    verb*: string
    pattern*: string
    handlerId*: int

var routes*: seq[Route] = @[]
const maxHeaders* = 32
const maxValueLen* = 256

proc registerRoute*(verb, pattern: string, handlerId: int) =
  routes.add(Route(verb: verb, pattern: pattern, handlerId: handlerId))

proc matchSegment(patternSeg, pathSeg: string): bool =
  if patternSeg == "*":
    return true
  return patternSeg == pathSeg

proc matchRoute*(verb, path: string): Route =
  for route in routes:
    if route.verb != verb:
      continue
    let patSegs = route.pattern.split('/')
    let pathSegs = path.split('/')
    if patSegs.len != pathSegs.len:
      continue
    var matched = true
    for j in 0 ..< patSegs.len:
      if not matchSegment(patSegs[j], pathSegs[j]):
        matched = false
        break
    if matched:
      return route
  raise newException(ValueError, "no matching route")

proc parseHeaderLine*(line: string): Header =
  let colon = line.find(':')
  if colon < 0:
    return Header(name: "", value: "")
  result.name = line[0 ..< colon].strip()
  result.value = line[colon + 1 ..^ 1].strip()

proc parseRequest*(raw: string): Request =
  let firstNl = raw.find('\n')
  if firstNl < 0:
    raise newException(ValueError, "malformed request")
  let reqLine = raw[0 ..< firstNl].strip()
  let parts = reqLine.split(' ')
  if parts.len < 2:
    raise newException(ValueError, "malformed request line")
  result.verb = parts[0]
  result.path = parts[1]
  var i = firstNl + 1
  while i < raw.len:
    let lineEnd = raw.find('\n', i)
    if lineEnd < 0:
      result.body = raw[i ..^ 1]
      break
    let line = raw[i ..< lineEnd]
    i = lineEnd + 1
    if line.strip().len == 0:
      result.body = raw[i ..^ 1]
      break
    let h = parseHeaderLine(line)
    if h.name.len > 0:
      if result.headers.len >= maxHeaders:
        raise newException(ValueError, "too many headers")
      if h.value.len > maxValueLen:
        raise newException(ValueError, "header value too long")
      result.headers.add(h)

proc parseVersion*(value: string): tuple[major, minor: int] =
  let parts = value.split('.')
  result.major = parseInt(parts[0])
  result.minor = parseInt(parts[1])

proc getContentLength*(req: Request): int =
  for h in req.headers:
    if h.name == "Content-Length":
      let consumed = parseSaturatedNatural(h.value, result)
      if consumed == 0:
        return -1
      return result
  return -1

proc hasHeader*(req: Request, name: string): bool =
  for h in req.headers:
    if h.name == name.toLowerAscii():
      return true
  return false

proc getApiVersion*(req: Request): tuple[major, minor: int] =
  for h in req.headers:
    if h.name == "X-Api-Version":
      return parseVersion(h.value)
  return (0, 0)

proc dispatch*(raw: string): string =
  try:
    let req = parseRequest(raw)
    let route = matchRoute(req.verb, req.path)
    let contentLen = getContentLength(req)
    if contentLen > 0 and req.body.len > contentLen:
      return "413"
    let version = getApiVersion(req)
    if version.major < 1:
      return "426"
    if hasHeader(req, "X-Trace-Id"):
      return "200 traced " & $route.handlerId
    return "200 " & $route.handlerId
  except ValueError:
    return "400"
