#include "raw_abi.h"

#include <stdlib.h>

struct RawHandle {
  RawConfig config;
};

RawHandle *raw_open(RawConfig config) {
  RawHandle *handle = malloc(sizeof(*handle));
  if (handle != NULL) {
    handle->config = config;
  }
  return handle;
}

void raw_close(RawHandle *handle) {
  free(handle);
}

RawSnapshot raw_apply(RawHandle *handle, const int *values, size_t len) {
  RawSnapshot result = {0, 0};
  size_t i;

  if (handle == NULL || values == NULL) {
    return result;
  }

  result.count = len;
  for (i = 0; i < len; ++i) {
    result.total +=
      ((long long)values[i] + handle->config.bias) * handle->config.scale;
  }
  return result;
}

size_t raw_config_size(void) {
  return sizeof(RawConfig);
}

size_t raw_config_bias_offset(void) {
  return offsetof(RawConfig, bias);
}

size_t raw_config_scale_offset(void) {
  return offsetof(RawConfig, scale);
}

size_t raw_config_label_offset(void) {
  return offsetof(RawConfig, label);
}

size_t raw_snapshot_size(void) {
  return sizeof(RawSnapshot);
}
