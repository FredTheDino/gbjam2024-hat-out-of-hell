extern vec4 b;
extern vec4 g;
extern vec4 w;
extern vec4 h;

bool roughly_equal(float a, float b) {
  return abs(a - b) < 0.2;
}

vec4 effect(vec4 hue, Image tex, vec2 texture_coords, vec2 screen_coords ){
  vec4 color = Texel(tex, texture_coords) * hue;
  if (color.a < 0.5) {
    return vec4(0.0, 0.0, 0.0, 0.0);
  }
  bool is_grayscale = roughly_equal(color.r, color.g)
                   && roughly_equal(color.r, color.b);
  if (!is_grayscale) {
    return h;
  }
  if (color.r < 0.3) {
    return b;
  }
  if (color.r < 0.8) {
    return g;
  }
  return w;
}
