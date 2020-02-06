#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#include <multiboot.h>
#include <driver/screen.h>
#include <stdlib/stdio.h>
#include <stdlib/string.h>

void kmain(multiboot_info_t* info) {
    term_init();

    multiboot_memory_map_t* entry = (multiboot_memory_map_t*) info->mmap_addr;
    while (entry < info->mmap_addr + info->mmap_length) {
        //kprintf("hello world");
        entry = (multiboot_memory_map_t *)((uintptr_t)entry + entry->size + sizeof (entry->size));
    }

    const char* shit = "Hello from maikuro";
    //term_write("test", 4);
    kprintf(shit);
}