#include "mini_uart.h"
#include "printf.h"

void uart_printf(const char* chunk) {
    uart_puts(chunk);  // just call uart_puts directly
}
