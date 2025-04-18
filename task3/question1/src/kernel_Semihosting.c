#include "mini_uart.h"
#include "printf.h"

void kernel_main() {
    uart_init();
    // give data in chunks of 4 please
    char buff1[5] = "Hell";
    char buff2[5] = "o wo";
    char buff3[5] = "rld!";
    char buff4[5] = "\n  ";  // newline with padding
    char buff5[5] = "veda";
    char buff6[5] = "nt,r";
    char buff7[5] = "aj m";
    char buff8[5] = "ukul";


    uart_printf(buff1);
    uart_printf(buff2);
    uart_printf(buff3);
    uart_printf(buff4);
    uart_printf(buff5);
    uart_printf(buff6);
    uart_printf(buff7);
    uart_printf(buff8);

    while (1) {
        char c = uart_getc();
        uart_putc(c);
    }
}
