SECTIONS
{
    .text.boot : { *(.text.boot) }
    .text : { *(.text) }
    .rodata : { *(.rodata) }
    .data : { *(.data) }
    . = ALIGN(0x8);
    bss_begin = .;
    .bss : { *(.bss*) }
    bss_end = .;

    . = ALIGN(16);
    stack_top = . + 0x1000;   /* 4KB stack */
    stack_bottom = .;
}
