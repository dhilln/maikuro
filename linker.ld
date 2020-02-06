
OUTPUT_FORMAT(elf64-x86-64)

ENTRY(_start)
SECTIONS
{
    kernel_virt_offset = 0xffffffff80000000;

    /* Multiboot section */
    . = 0x100000;
    .multiboot ALIGN(4K) : AT(ADDR(.multiboot))
    {
        *(.multiboot)
    }

    /* Begin putting sections at kernel_phys_offfset + 0x100000 */
    . = kernel_virt_offset + 0x200000;
    .text ALIGN(4K) :  AT(ADDR(.text) - kernel_virt_offset)
    {
        sections_text = . - kernel_virt_offset;
        KEEP(*(.text))
        sections_text_end = . - kernel_virt_offset;
    }

    /* Read-only data */
    .rodata ALIGN(4K) :  AT(ADDR(.rodata) - kernel_virt_offset)
    {
        sections_rodata = . - kernel_virt_offset;
        KEEP(*(.rodata*))
        sections_rodata_end = . - kernel_virt_offset;
    }

    /* Read-write data (initialized) */
	.data ALIGN(4K) :  AT(ADDR(.data) - kernel_virt_offset)
	{
		sections_data = . - kernel_virt_offset;
        KEEP(*(.data*))
        sections_data_end = . - kernel_virt_offset;
	}
 
	/* Read-write data (uninitialized) and stack */
	.bss ALIGN(4K) :  AT(ADDR(.bss) - kernel_virt_offset)
	{
		sections_bss = . - kernel_virt_offset;
        KEEP(*(COMMON))
        KEEP(*(.bss*))
        sections_bss_end = . - kernel_virt_offset;
	}
}