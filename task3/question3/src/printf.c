#include "printf.h"
#include "utils.h"
#include "peripherals/base.h"

#define UART0_DR   (UART_BASE + 0x00)
#define UART0_FR   (UART_BASE + 0x18)

static void uart_putc(char c) {
    while (*(volatile unsigned int*)(UART0_FR) & (1 << 5));
    *(volatile unsigned int*)(UART0_DR) = c;
}

static void uart_puts(const char *s) {
    while (*s) {
        uart_putc(*s++);
    }
}

static void print_hex(unsigned int n) {
    char hex_digits[] = "0123456789ABCDEF";
    for (int i = 7; i >= 0; i--) {
        uart_putc(hex_digits[(n >> (i * 4)) & 0xF]);
    }
}

static void print_dec(int n) {
    if (n < 0) {
        uart_putc('-');
        n = -n;
    }

    char buf[10];
    int i = 0;
    do {
        buf[i++] = '0' + (n % 10);
        n /= 10;
    } while (n > 0);

    while (--i >= 0) uart_putc(buf[i]);
}

void printf(const char *fmt, ...) {
    __builtin_va_list args;
    __builtin_va_start(args, fmt);

    for (const char *p = fmt; *p; p++) {
        if (*p != '%') {
            uart_putc(*p);
            continue;
        }

        p++;
        switch (*p) {
            case 's': uart_puts(__builtin_va_arg(args, const char*)); break;
            case 'c': uart_putc((char)__builtin_va_arg(args, int)); break;
            case 'x': print_hex(__builtin_va_arg(args, unsigned int)); break;
            case 'd': print_dec(__builtin_va_arg(args, int)); break;
            case 'u': print_dec(__builtin_va_arg(args, unsigned int)); break;
            case '%': uart_putc('%'); break;
            default:  uart_putc('?'); break;
        }
    }

    __builtin_va_end(args);
}

void printf_init() {
    // Optional: if UART init is needed
    // But if already set up elsewhere (e.g., mini_uart.c), leave empty
}
