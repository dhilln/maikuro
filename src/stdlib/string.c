/**
 * maikuro
 * Copyright (c) maikuro developers
**/

#include <stdlib/string.h>

size_t strlen(const char* s) {
    size_t len = 0;
    while (s[len])
        len++;
    return len;
}

size_t strcmp(const char *s1, const char* s2) {
    while (*s1 && (*s1 == *s2)) {
        s1++;
        s2++;
    }

    return *(const unsigned char*)s1 - *(const unsigned char*)s2;
}