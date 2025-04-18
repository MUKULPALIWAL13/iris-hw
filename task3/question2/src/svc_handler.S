.global svc_handler
svc_handler:
    ldr r0, =svc_msg

print_loop:
    ldrb r1, [r0], #1
    cmp r1, #0
    beq svc_done
    bl uart_send
    b print_loop

svc_done:
    b .
    
.data
svc_msg:
    .asciz "SVC called\n"
