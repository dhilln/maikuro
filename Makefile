.PHONY: run clean

CC=gcc
CFLAGS=-ffreestanding -Wall -Wextra	   \
		-gdwarf						   \
		-Isrc					       \
		-fno-pic                       \
		-mcmodel=kernel				   \
		-mno-sse                       \
		-mno-sse2                      \
		-mno-mmx                       \
		-mno-80387                     \
		-mno-red-zone                  \
		-ffreestanding                 \
		-fno-stack-protector           \
		-fno-omit-frame-pointer        \

SOURCES = $(shell find src/ -type f -name '*.c')
HEADERS = $(shell find src/ -type f -name '*.h')
ASMFILE = $(shell find src/ -type f -name '*.asm')
OBJECTS = ${SOURCES:.c=.o} ${ASMFILE:.asm=.o}

maikuro.iso: kernel.elf
	@mkdir -p build/iso/boot/grub
	@cp kernel.elf build/iso/boot/kernel.bin
	@cp grub.cfg build/iso/boot/grub
	@grub-mkrescue -o maikuro.iso build/iso 2> /dev/null
	@rm -r build/iso

kernel.elf: ${OBJECTS}
	ld -n -T linker.ld -z max-page-size=0x1000 -nostdlib -o $@ ${OBJECTS}

%.o: %.c ${HEADERS}
	${CC} ${CFLAGS} -c $< -nostdlib -o $@

%.o: %.asm
	nasm -felf64 -F dwarf -g $< -o $@

run: maikuro.iso
	@qemu-system-x86_64 -smp cpus=4 -cdrom maikuro.iso -m 4G -no-reboot -monitor stdio -d int -no-shutdown -vga vmware

clean:
	-rm kernel.elf
	-rm maikuro.iso
	-rm ${OBJECTS}
