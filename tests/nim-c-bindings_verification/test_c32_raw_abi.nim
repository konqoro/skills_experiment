## Verifies opaque imports and by-value structs across a real C ABI boundary.

import std/os

const
  testDir = currentSourcePath.parentDir
  sourceDir = testDir / "test_c32_raw_abi_src"
  header = sourceDir / "raw_abi.h"

{.compile: sourceDir / "raw_abi.c".}

type
  RawHandleObj {.
      importc: "RawHandle", header: header, incompleteStruct.} = object
  RawHandle = ptr RawHandleObj

  RawConfig {.importc: "RawConfig", header: header, bycopy.} = object
    bias: cint
    scale: cuint
    label: cstring

  RawSnapshot {.importc: "RawSnapshot", header: header, bycopy.} = object
    count: csize_t
    total: clonglong

{.push cdecl, header: header.}

proc rawOpen(config: RawConfig): RawHandle {.importc: "raw_open".}
proc rawClose(handle: RawHandle) {.importc: "raw_close".}
proc rawApply(
  handle: RawHandle;
  values: ptr cint;
  len: csize_t
): RawSnapshot {.importc: "raw_apply".}

proc rawConfigSize(): csize_t {.importc: "raw_config_size".}
proc rawConfigBiasOffset(): csize_t {.importc: "raw_config_bias_offset".}
proc rawConfigScaleOffset(): csize_t {.importc: "raw_config_scale_offset".}
proc rawConfigLabelOffset(): csize_t {.importc: "raw_config_label_offset".}
proc rawSnapshotSize(): csize_t {.importc: "raw_snapshot_size".}

{.pop.}

doAssert csize_t(sizeof(RawConfig)) == rawConfigSize()
doAssert csize_t(offsetOf(RawConfig, bias)) == rawConfigBiasOffset()
doAssert csize_t(offsetOf(RawConfig, scale)) == rawConfigScaleOffset()
doAssert csize_t(offsetOf(RawConfig, label)) == rawConfigLabelOffset()
doAssert csize_t(sizeof(RawSnapshot)) == rawSnapshotSize()

let config = RawConfig(bias: 2, scale: 3, label: "probe")
let handle = rawOpen(config)
doAssert handle != nil

let values = [1.cint, 4.cint, 7.cint]
let snapshot = rawApply(handle, addr values[0], csize_t(values.len))
doAssert snapshot.count == 3
doAssert snapshot.total == 54

rawClose(handle)

echo "C32: PASS"
