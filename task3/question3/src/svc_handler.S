.global svc_handler
svc_handler:
    sub lr, lr, #4
    stmfd sp!, {r0-r12, lr}
    ldr r0, [lr]          // Get SVC instruction
    and r0, r0, #0xFF     // Extract syscall number
    cmp r0, #0
    bne 1f                // If not 0, jump to unknown_svc
    bl handle_syscall
    b 2f                  // Go to done

1:  // unknown_svc:
    // You can optionally print error here

2:  // done:
    ldmfd sp!, {r0-r12, lr}
    movs pc, lr
