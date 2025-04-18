.section ".vectors", "ax"
.global vectors_start
vectors_start:
    b reset
    b undefined_instruction
    b svc_handler
    b prefetch_abort
    b data_abort
    b reserved
    b irq
    b fiq

reset:
    b .
undefined_instruction:
    b .
svc_handler:
    b svc_handler
prefetch_abort:
    b .
data_abort:
    b .
reserved:
    b .
irq:
    b .
fiq:
    b .
