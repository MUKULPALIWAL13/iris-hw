.section ".text.boot"

.global _start

.extern kernel_main
_start:

    ldr sp, =stack_top        // Set stack pointer to top of the stack



    bl kernel_main            // Jump to C function

hang:

    b hang                    // Infinite loop if kernel_main returns