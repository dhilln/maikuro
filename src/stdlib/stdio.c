/**
 * maikuro
 * Copyright (c) maikuro developers
**/

#include <stdlib/stdio.h>

void kprintf(const char* format, ...) {
    va_list argp;
    va_start(argp, format);

    while (*format) {
        if (*format == '%') {
            if (*format == '%') {
                term_putchar('%');
            }
            else if (*format == 'c') {
                char c = va_arg(argp, char);
                term_putchar(c);
            }
        }
        else {
            term_putchar(*format);
        }
        format++;
    }

    va_end(argp);    
}