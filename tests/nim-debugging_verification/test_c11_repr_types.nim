import std/[assertions, strutils]

type
  MyRef = ref object
    x: int
    s: string

proc main() =
  var r = MyRef(x: 42, s: "hello")
  var seq1 = @[1, 2, 3]
  var str1 = "world"
  var p = alloc(16)

  let reprR = repr(r)
  let reprSeq = repr(seq1)
  let reprStr = repr(str1)
  let reprP = repr(p)
  dealloc(p)

  doAssert reprR.contains("x: 42"), reprR
  doAssert reprR.contains("s: \"hello\""), reprR
  doAssert reprSeq.contains("@[1, 2, 3]"), reprSeq
  doAssert reprStr == "\"world\"", reprStr
  doAssert reprP.len >= 4, reprP
  echo "C11: PASS"

main()
