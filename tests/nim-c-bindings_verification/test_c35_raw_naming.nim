## Test C35: In raw bindings, matching C identifier names directly lets importc
## resolve without an explicit string. Explicit importc is needed only for
## keyword collisions or necessary renames.

import std/os

const
  testDir = currentSourcePath.parentDir
  sourceDir = testDir / "test_c35_raw_naming_src"
  header = sourceDir / "raw_naming.h"

{.compile: sourceDir / "raw_naming.c".}

# When the Nim name matches the C name, importc resolves without an explicit string
{.push cdecl, header: header, importc.}
proc raw_add(a: cint; b: cint): cint
{.pop.}

# C name "type" collides with Nim keyword — rename and use explicit importc
proc typ(x: cint): cint {.cdecl, header: header, importc: "type".}

doAssert raw_add(3, 4) == 7
doAssert typ(5) == 10

echo "C35: PASS"
