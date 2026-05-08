import std/[parseutils, strutils]

type
  WireVersion* = tuple[orig: string, major, minor: int]
  Message* = object
    kind*: string
    target*: string
    version*: WireVersion
    payloadLen*: int

const maxPayload* = 4096

proc parseWireVersion*(token: string): WireVersion =
  result = default(WireVersion)
  var i = token.skipIgnoreCase("WIRE/")
  if i != 5:
    raise newException(ValueError, "invalid wire version: " & token)
  result.orig = token
  i.inc token.parseSaturatedNatural(result.major, i)
  i.inc
  i.inc token.parseSaturatedNatural(result.minor, i)

proc parsePayloadLen*(value: string): int =
  let consumed = parseSaturatedNatural(value, result)
  if consumed == 0:
    raise newException(ValueError, "invalid payload length")
  if result > maxPayload:
    raise newException(ValueError, "payload too large")

proc parseMessage*(line: string): Message =
  let parts = line.split(' ')
  if parts.len != 4:
    raise newException(ValueError, "expected four fields")
  result.kind = parts[0]
  result.target = parts[1]
  result.version = parseWireVersion(parts[2])
  result.payloadLen = parsePayloadLen(parts[3])

proc handleMessage*(line: string): bool =
  try:
    discard parseMessage(line)
    result = true
  except ValueError:
    result = false
