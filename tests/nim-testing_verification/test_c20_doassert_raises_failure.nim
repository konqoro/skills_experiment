import std/[assertions, os]

let workDir = getTempDir() / ("nim_testing_c20_" & $getCurrentProcessId())

proc writeCase(name, body: string): string =
  result = workDir / (name & ".nim")
  writeFile(result, body)

proc runCase(path: string): int =
  execShellCmd("nim c -r --hints:off --verbosity:0 " & path)

createDir(workDir)
try:
  let passing = writeCase("passing", """
import std/assertions

block expected_value_error:
  doAssertRaises ValueError:
    raise newException(ValueError, "expected")
""")

  let noRaise = writeCase("no_raise", """
import std/assertions

block no_exception:
  doAssertRaises ValueError:
    discard
""")

  let wrongType = writeCase("wrong_type", """
import std/assertions

block wrong_exception:
  doAssertRaises ValueError:
    raise newException(IOError, "wrong type")
""")

  let defectPass = writeCase("defect_pass", """
import std/assertions

block expected_defect:
  doAssertRaises AssertionDefect:
    doAssert false
""")

  doAssert runCase(passing) == 0, "C20: matching exception should pass"
  doAssert runCase(noRaise) != 0, "C20: missing exception should fail"
  doAssert runCase(wrongType) != 0, "C20: wrong exception type should fail"
  doAssert runCase(defectPass) == 0, "C20: matching Defect type should pass"

  echo "C20: PASS"
finally:
  removeDir(workDir)
