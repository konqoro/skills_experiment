#include <stdint.h>
#include <string.h>

typedef struct {
  uint8_t r;
  uint8_t g;
  uint8_t b;
  uint8_t a;
} Color;

typedef struct {
  float x;
  float y;
  float width;
  float height;
} Rect;

typedef struct {
  uint32_t id;
  int32_t width;
  int32_t height;
} Texture;

Texture lib_load_texture(const char *path) {
  Texture result = {0, 0, 0};
  if (path != NULL && strcmp(path, "test.png") == 0) {
    result.id = 7;
    result.width = 64;
    result.height = 32;
  }
  return result;
}

void lib_unload_texture(Texture texture) {
  (void)texture;
}

void lib_draw_texture(Texture texture, Rect source, Rect dest, Color color) {
  (void)texture;
  (void)source;
  (void)dest;
  (void)color;
}
