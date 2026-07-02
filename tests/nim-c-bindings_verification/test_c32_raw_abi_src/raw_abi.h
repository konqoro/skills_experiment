#ifndef RAW_ABI_H
#define RAW_ABI_H

#include <stddef.h>

typedef struct RawHandle RawHandle;

typedef struct {
  int bias;
  unsigned int scale;
  const char *label;
} RawConfig;

typedef struct {
  size_t count;
  long long total;
} RawSnapshot;

RawHandle *raw_open(RawConfig config);
void raw_close(RawHandle *handle);
RawSnapshot raw_apply(RawHandle *handle, const int *values, size_t len);

size_t raw_config_size(void);
size_t raw_config_bias_offset(void);
size_t raw_config_scale_offset(void);
size_t raw_config_label_offset(void);
size_t raw_snapshot_size(void);

#endif
