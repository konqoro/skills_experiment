## Expected link failure: header defeats runtime-only dynlib resolution.

const helperLibrary = "/tmp/libnim_c_bindings_c33.so"

proc helperAdd(a, b: cint): cint {.
  cdecl,
  dynlib: helperLibrary,
  header: "third_party/c07_local_helper/c07_local_helper.h",
  importc: "c07_helper_add".}

doAssert helperAdd(20, 22) == 42
