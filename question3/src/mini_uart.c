#include "mini_uart.h"
#include "utils.h"
#include "peripherals/base.h"

#define AUX_ENABLES     (PERIPHERAL_BASE + 0x215004)
#define AUX_MU_IO_REG   (PERIPHERAL_BASE + 0x215040)
#define AUX_MU_IER_REG  (PERIPHERAL_BASE + 0x215044)
#define AUX_MU_IIR_REG  (PERIPHERAL_BASE + 0x215048)
#define AUX_MU_LCR_REG  (PERIPHERAL_BASE + 0x21504C)
#define AUX_MU_MCR_REG  (PERIPHERAL_BASE + 0x215050)
#define AUX_MU_LSR_REG  (PERIPHERAL_BASE + 0x215054)
#define AUX_MU_CNTL_REG (PERIPHERAL_BASE + 0x215060)
#define AUX_MU_BAUD_REG (PERIPHERAL_BASE + 0x215068)
#define GPFSEL1         (PERIPHERAL_BASE + 0x200004)
#define GPPUD           (PERIPHERAL_BASE + 0x200094)
#define GPPUDCLK0       (PERIPHERAL_BASE + 0x200098)

void uart_init() {
    put32(AUX_ENABLES, 1);                 // Enable mini UART
    put32(AUX_MU_CNTL_REG, 0);             // Disable TX/RX during config
    put32(AUX_MU_IER_REG, 0);              // Disable interrupts
    put32(AUX_MU_LCR_REG, 3);              // 8-bit mode
    put32(AUX_MU_MCR_REG, 0);              // No RTS/CTS
    put32(AUX_MU_BAUD_REG, 270);           // 115200 baud @ 250 MHz

    // GPIO14 (TXD) and GPIO15 (RXD) to ALT5
    unsigned int selector = get32(GPFSEL1);
    selector &= ~(7 << 12);                // clear GPIO14
    selector |= 2 << 12;                   // ALT5
    selector &= ~(7 << 15);                // clear GPIO15
    selector |= 2 << 15;                   // ALT5
    put32(GPFSEL1, selector);

    put32(GPPUD, 0);                       // Disable pull-up/down
    delay(150);
    put32(GPPUDCLK0, (1 << 14) | (1 << 15));
    delay(150);
    put32(GPPUDCLK0, 0);

    put32(AUX_MU_CNTL_REG, 3);             // Enable TX and RX
}

void uart_send(char c) {
    while (!(get32(AUX_MU_LSR_REG) & 0x20));
    put32(AUX_MU_IO_REG, c);
}

char uart_recv() {
    while (!(get32(AUX_MU_LSR_REG) & 0x01));
    return (char)(get32(AUX_MU_IO_REG) & 0xFF);
}

void uart_puts(const char *s) {
    while (*s) {
        if (*s == '\n') uart_send('\r');
        uart_send(*s++);
    }
}
