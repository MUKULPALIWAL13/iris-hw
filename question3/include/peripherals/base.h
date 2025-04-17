// peripherals.h - Define peripheral memory addresses
#ifndef PERIPHERALS_H
#define PERIPHERALS_H

// Base addresses - update with your actual addresses
#define PERIPHERAL_BASE     0x3F000000  // BCM2835/BCM2836 Raspberry Pi peripheral base
#define UART_BASE           (PERIPHERAL_BASE + 0x215000)  // Mini UART base address

#endif /* PERIPHERALS_H */