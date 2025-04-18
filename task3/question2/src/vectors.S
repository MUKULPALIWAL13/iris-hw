.section .text
.global vectors
vectors:
    ldr pc, _reset
    ldr pc, _undefined
    ldr pc, _svc
    ldr pc, _prefetch
    ldr pc, _abort
    ldr pc, _reserved
    ldr pc, _irq
    ldr pc, _fiq

_reset:     .word _start
_undefined: .word hang
_svc:       .word svc_handler
_prefetch:  .word hang
_abort:     .word hang
_reserved:  .word hang
_irq:       .word hang
_fiq:       .word hang

hang:
    b hang
