#include "lib.h"
#include <cstdio>

struct LibInitializer {
    LibInitializer() { printf("initialize lib1\n"); }
} lib_initializer;
