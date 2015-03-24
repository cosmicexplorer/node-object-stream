#include <string.h>

#include "libmylib.h"

void set_zero(size_t * s) {
  if (0 != s) {
    *s = 0;
  }
}

const char * get_str(const char * s, size_t * num_s_occur) {
  size_t str_size = strlen(s);
  for (size_t i = 0; i < str_size; ++i) {
    if (s[i] == 's') {
      ++*num_s_occur;
    }
  }
  return "done";
}
