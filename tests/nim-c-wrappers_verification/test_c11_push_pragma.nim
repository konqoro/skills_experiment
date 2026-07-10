# Test C11: {.push callconv: cdecl, importc, header: ...} scoped pragma blocks
# importc in the push block resolves C symbols from Nim proc names
{.push callconv: cdecl, importc, header: "<stdlib.h>".}
proc malloc(size: csize_t): pointer
proc free(p: pointer)
{.pop.}

var p = malloc(64)
doAssert p != nil
free(p)

echo "C11: PASS"
