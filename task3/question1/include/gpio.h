#ifndef GPIO_H
#define GPIO_H

#include "mm.h"

// GPIO
#define GPIO_BASE           (MMIO_BASE + 0x200000)

// GPIO Function Select
#define GPFSEL0             ((volatile unsigned int*)(GPIO_BASE + 0x00))
#define GPFSEL1             ((volatile unsigned int*)(GPIO_BASE + 0x04))
#define GPFSEL2             ((volatile unsigned int*)(GPIO_BASE + 0x08))

// GPIO Pull-up/down
#define GPPUD               ((volatile unsigned int*)(GPIO_BASE + 0x94))
#define GPPUDCLK0           ((volatile unsigned int*)(GPIO_BASE + 0x98))
#define GPPUDCLK1           ((volatile unsigned int*)(GPIO_BASE + 0x9C))

#endif /* GPIO_H */