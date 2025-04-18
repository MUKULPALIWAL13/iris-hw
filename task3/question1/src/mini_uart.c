#include "gpio.h"
#include "mini_uart.h"

// Function for short delay
static void delay(unsigned int cycles) {
    while (cycles--) {
        asm volatile("nop");
    }
}

void uart_init() {
    // Disable UART0
    *UART0_CR = 0;
    
    // Setup GPIO pins 14 and 15 for UART0
    unsigned int selector = *GPFSEL1;
    selector &= ~(7 << 12);  // Clear bits 12-14 (GPIO14)
    selector |= 4 << 12;     // Set GPIO14 to ALT0 (UART0 TXD)
    selector &= ~(7 << 15);  // Clear bits 15-17 (GPIO15)
    selector |= 4 << 15;     // Set GPIO15 to ALT0 (UART0 RXD)
    *GPFSEL1 = selector;
    
    // Disable pull-up/down
    *GPPUD = 0;
    delay(150);
    
    // Clock the control signal into the GPIO pads
    *GPPUDCLK0 = (1 << 14) | (1 << 15);
    delay(150);
    
    // Remove the clock
    *GPPUDCLK0 = 0;
    
    // Clear all pending interrupts
    *UART0_ICR = 0x7FF;
    
    // Set integer & fractional part of baud rate
    // Divider = UART_CLOCK/(16 * Baud)
    // UART_CLOCK is system clock (48MHz in QEMU)
    // Baud = 115200
    // Divider = 48000000/(16 * 115200) = 26.0416667
    // Integer part = 26
    // Fractional part = (.0416667 * 64) + 0.5 = 3.1667 = 3
    *UART0_IBRD = 26;
    *UART0_FBRD = 3;
    
    // Enable FIFO & 8-bit data transmission (1 stop bit, no parity)
    *UART0_LCRH = (1 << 4) | (1 << 5) | (1 << 6);
    
    // Mask all interrupts
    *UART0_IMSC = (1 << 1) | (1 << 4) | (1 << 5) | (1 << 6) |
              (1 << 7) | (1 << 8) | (1 << 9) | (1 << 10);
    
    // Enable UART0, receive & transfer part of UART
    *UART0_CR = (1 << 0) | (1 << 8) | (1 << 9);
}

// Send a character
void uart_putc(unsigned char c) {
    // Wait for UART to become ready to transmit
    while (*UART0_FR & (1 << 5));
    
    // Write character to data register
    *UART0_DR = c;
}

// Receive a character
unsigned char uart_getc() {
    // Wait for UART to have received something
    while (*UART0_FR & (1 << 4));
    
    // Read from data register
    return *UART0_DR & 0xFF;
}

// Send a string
void uart_puts(const char* str) {
    while (*str) {
        // Handle newline with carriage return
        if (*str == '\n')
            uart_putc('\r');
        uart_putc(*str++);
    }
}

// NEW FUNCTION: Receive a string of up to max_len characters
// Returns the number of characters read
int uart_gets(char* buffer, int max_len) {
    int i = 0;
    char c;
    
    // Read up to max_len-1 characters (leave space for null terminator)
    while (i < max_len - 1) {
        c = uart_getc();
        
        // Handle backspace/delete
        if (c == '\b' || c == 127) {
            if (i > 0) {
                i--;
                // Optional: Echo backspace to terminal
                uart_puts("\b \b");
            }
            continue;
        }
        
        // Break on newline or carriage return
        if (c == '\n' || c == '\r') {
            uart_puts("\r\n");  // Echo newline
            break;
        }
        
        // Echo character back to terminal
        uart_putc(c);
        
        // Store character in buffer
        buffer[i++] = c;
    }
    
    // Null terminate the string
    buffer[i] = '\0';
    
    return i;
}

// Example function to read 10 characters
void read_10_chars(char* buffer) {
    int i;
    
    for (i = 0; i < 10; i++) {
        buffer[i] = uart_getc();
        
        // Echo character back
        uart_putc(buffer[i]);
    }
    
    // Null terminate the string
    buffer[10] = '\0';
}