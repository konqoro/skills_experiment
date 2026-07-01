type
  WordScanner = object
    input: string
    pos: int
    opened: bool

proc open(scanner: var WordScanner; input: string) =
  scanner = WordScanner(input: input, opened: true)

proc skipSpaces(scanner: var WordScanner) =
  while scanner.pos < scanner.input.len and scanner.input[scanner.pos] == ' ':
    inc scanner.pos

proc next(scanner: var WordScanner): string =
  doAssert scanner.opened
  scanner.skipSpaces()
  let start = scanner.pos
  while scanner.pos < scanner.input.len and scanner.input[scanner.pos] != ' ':
    inc scanner.pos
  result = scanner.input[start..<scanner.pos]

proc close(scanner: var WordScanner) =
  scanner = WordScanner()

var scanner: WordScanner
scanner.open("alpha beta")
doAssert scanner.next() == "alpha"
doAssert scanner.next() == "beta"
doAssert scanner.next() == ""
scanner.close()
doAssert not scanner.opened

echo "ref_parser_state_pattern: PASS"
