%define kernel_virt_offset 0xffffffff80000000

;; Multiboot shit
MBALIGN  equ 1 << 0              ;; align loaded modules on page boundaries
MEMINFO  equ 1 << 1              ;; provide memory map
FLAGS    equ MBALIGN | MEMINFO   ;; multiboot 'flag' field
MAGIC    equ 0x1BADB002          ;; magic number
CHECKSUM equ -(MAGIC + FLAGS)    ;; checksum of above, proves we are multiboot

section .multiboot
align 4
    dd MAGIC
    dd FLAGS
    dd CHECKSUM

section .bss
align 16
stack_bottom:
resb 16384 ;; 16 KiB

stack_top:

section .text
global _start
bits 32
_start:
    extern gdt_ptr_lowerhalf

    ;; The bootloader has loaded us into 32-bit protected mode on a x86
	;; machine. Interrupts are disabled. Paging is disabled. The processor
	;; state is as defined in the multiboot standard. The kernel has full
	;; control of the CPU.

    ;; We set esp register to point to the top of our stack
    mov esp, stack_top - kernel_virt_offset

    mov edi, multiboot_header_ptr - kernel_virt_offset
    mov DWORD [edi], ebx

    mov eax, p4_table - kernel_virt_offset
    mov cr3, eax

    ;; Enable PAE
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ;; Long mode bit
    mov ecx, 0xc0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ;; Enabling paging
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ;; Load the GDT
    lgdt [gdt_ptr_lowerhalf - kernel_virt_offset]
    jmp 0x8:(higher_half_entry - kernel_virt_offset)

bits 64
higher_half_entry:
    mov rax, higher_half
    jmp rax
higher_half:
    lgdt [gdt_ptr_lowerhalf]
    jmp start64
start64:
    mov ax, 0
    mov gs, ax
    mov ds, ax
    mov fs, ax
    mov ss, ax
    mov es, ax

    ;;mov rdi, ebx
    mov edi, DWORD [multiboot_header_ptr]

    ;; Enter the high-level kernel
    extern kmain
	call kmain
.hang:	
    hlt
	jmp .hang
.end:

section .bss
align 16
global multiboot_header_ptr
multiboot_header_ptr:
    resb 16

section .data
;; Paging shit

align 4096      ;; Align by 4096
p2_table:
    dq 0 + 0x83
    dq 0x200000 + 0x83
    times 510 dq 0

p3_table:
    dq (p2_table - kernel_virt_offset) + 0x3
    times 509 dq 0
    dq (p2_table - kernel_virt_offset) + 0x3
    dq 0

p4_table:
    dq (p3_table - kernel_virt_offset) + 0x3
    times 510 dq 0
    dq (p3_table - kernel_virt_offset) + 0x3