import std/assertions

var unordered = @[10, 20, 30, 40]
unordered.del 1
doAssert unordered == @[10, 40, 30]

var ordered = @[10, 20, 30, 40]
ordered.delete 1
doAssert ordered == @[10, 30, 40]

echo "C40 C41: PASS"
