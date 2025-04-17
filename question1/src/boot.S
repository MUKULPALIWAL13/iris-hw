.section ".text.boot"

.global _start

_start:
    // Check processor ID, halt all non-primary cores
    mrc p15, 0, r1, c0, c0, 5
    and r1, r1, #3
    cmp r1, #0
    bne halt

    // Set up stack pointer
    mov sp, #0x8000
    
    // Clear the BSS section
    ldr r4, =_bss_start
    ldr r9, =_bss_end
    mov r5, #0
    mov r6, #0
    mov r7, #0
    mov r8, #0
    b       2f

1:  // Store multiple at r4.
    stmia r4!, {r5-r8}

2:  // If we're still below bss_end, loop.
    cmp r4, r9
    blo 1b

    // Jump to kernel_main
    bl kernel_main

    // If we return from kernel_main, halt the CPU
halt:
    wfe
    b halt