## Verifies that dynlib imports load a real shared library without link flags.

import std/os

const
  testDir = currentSourcePath.parentDir
  helperDir = testDir / "third_party/c07_local_helper"
  helperSource = helperDir / "c07_local_helper.c"

when defined(linux):
  const helperLibrary = "/tmp/libnim_c_bindings_c33.so"

  static:
    let build = gorgeEx(
      "cc -shared -fPIC -o " & quoteShell(helperLibrary) & " " &
      quoteShell(helperSource)
    )
    doAssert build.exitCode == 0, build.output

  proc helperAdd(a, b: cint): cint {.
    cdecl,
    dynlib: helperLibrary,
    importc: "c07_helper_add".}

  doAssert helperAdd(20, 22) == 42

echo "C33: PASS"
