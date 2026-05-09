import std/parseutils

var value = 0
let consumed = parseSaturatedNatural("12abc", value)

doAssert consumed == 2
doAssert value == 12
doAssert consumed != "12abc".len

echo "C05: PASS"
