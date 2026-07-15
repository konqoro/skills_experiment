import std/assertions

type Port = range[1..65535]

proc acceptPort(port: Port): int =
  port

proc acceptPositive(value: Positive): int =
  value

let port = 8080
let count = 3

doAssert acceptPort(port) == 8080
doAssert acceptPositive(count) == 3

echo "C47: PASS"
