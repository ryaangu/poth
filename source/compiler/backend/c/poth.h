#ifndef POTH_H
#define POTH_H

#include <stdint.h>

void poth_print_int8_t (int8_t  value);
void poth_print_int16_t(int16_t value);
void poth_print_int32_t(int32_t value);
void poth_print_int64_t(int64_t value);

typedef float  float32_t;
typedef double float64_t;

void poth_print_float32_t(float32_t value);
void poth_print_float64_t(float64_t value);

typedef const char *string_t;

void poth_print_string_t(string_t value);

#endif