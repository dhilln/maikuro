/**
 * maikuro
 * Copyright (c) maikuro developers
**/

#include <driver/screen.h>

static const size_t VGA_WIDTH = 80;
static const size_t VGA_HEIGHT = 25;

size_t    term_row;
size_t    term_col;
uint8_t   term_color;
uint16_t* term_buffer;

void term_init() {
    /* Initialize the terminal */

    term_row    = 0;
    term_col    = 0;
    term_color  = vga_entry_color(VGA_COLOR_LIGHT_GREEN, VGA_COLOR_BLACK);
    term_buffer = (uint16_t*) 0xB8000;

    for (size_t y = 0; y < VGA_HEIGHT; y++) {
        for (size_t x = 0; x < VGA_WIDTH; x++) {
            const size_t index = y * VGA_WIDTH + x;
            term_buffer[index] = vga_entry(' ', term_color);
        }
    }
}

void term_setcolor(uint8_t color) {
	term_color = color;
}

void term_putentryat(char c, uint8_t color, size_t x, size_t y) {
	const size_t index = y * VGA_WIDTH + x;
	term_buffer[index] = vga_entry(c, color);
}

void term_putchar(char c) {
	term_putentryat(c, term_color, term_col, term_row);
	if (++term_col == VGA_WIDTH) {
		term_col = 0;
		if (++term_row == VGA_HEIGHT)
			term_row = 0;
	}
}

void term_write(const char* data, size_t size) {
    /* shittier kprintf */
	for (size_t i = 0; i < size; i++)
		term_putchar(data[i]);
}