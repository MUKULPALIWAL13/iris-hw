ENTRY(_start)
 
SECTIONS
{
    /* Kernel loads at 0x8000 physical address */
    . = 0x8000;
    
    /* First goes the boot code */
    .text.boot : {
        *(.text.boot)
    }
    
    /* Then regular code */
    .text : {
        *(.text)
    }
    
    /* Read-only data */
    .rodata : {
        *(.rodata)
    }
    
    /* Read-write data (initialized) */
    .data : {
        *(.data)
    }
    
    /* Read-write data (uninitialized) and stack */
    _bss_start = .;
    .bss : {
        *(.bss)
    }
    _bss_end = .;
}