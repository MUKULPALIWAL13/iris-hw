.global switch_to_el0
.global user_stack_top

switch_to_el0:
    // r0 = address of user_main
    mov r4, r0                // Save user_main into r4

    // Switch to SYS mode (0x1F) first — allows us to set SP_usr
    mrs r0, cpsr
    bic r0, r0, #0x1F
    orr r0, r0, #0x1F         // System mode (same as user, but privileged)
    msr cpsr_c, r0

    // Set SP_usr via SYS mode (can access banked SP)
    ldr sp, =user_stack_top

    // Now switch to true user mode (unprivileged)
    mrs r0, cpsr
    bic r0, r0, #0x1F
    orr r0, r0, #0x10         // User mode
    msr cpsr_c, r0

    // Now we're in user mode with proper stack — jump to user_main
    mov lr, r4
    bx lr

    // Should never return here
    b .
.section .bss
.align 8
user_stack:
    .space 4096
user_stack_top: