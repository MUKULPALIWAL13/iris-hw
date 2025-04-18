#ifndef PL011_UART_H
#define PL011_UART_H

#include "mm.h"

// PL011 UART (UART0) - Better supported in QEMU
#define UART0_BASE          (MMIO_BASE + 0x201000)
#define UART0_DR            ((volatile unsigned int*)(UART0_BASE + 0x00))
#define UART0_FR            ((volatile unsigned int*)(UART0_BASE + 0x18))
#define UART0_IBRD          ((volatile unsigned int*)(UART0_BASE + 0x24))
#define UART0_FBRD          ((volatile unsigned int*)(UART0_BASE + 0x28))
#define UART0_LCRH          ((volatile unsigned int*)(UART0_BASE + 0x2C))
#define UART0_CR            ((volatile unsigned int*)(UART0_BASE + 0x30))
#define UART0_IMSC          ((volatile unsigned int*)(UART0_BASE + 0x38))
#define UART0_ICR           ((volatile unsigned int*)(UART0_BASE + 0x44))

// Function prototypes
void uart_init();
void uart_putc(unsigned char c);
unsigned char uart_getc();
void uart_puts(const char* str);

// New function prototypes
int uart_gets(char* buffer, int max_len);
void read_10_chars(char* buffer);

#endif /* PL011_UART_H */