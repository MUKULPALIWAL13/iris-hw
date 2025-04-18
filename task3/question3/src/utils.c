#include "utils.h"

void delay(unsigned int count) {
    for (unsigned int i = 0; i < count; i++) {
        asm volatile("nop");
    }
}

void put32(unsigned int addr, unsigned int value) {
    *(volatile unsigned int*)addr = value;
}

unsigned int get32(unsigned int addr) {
    return *(volatile unsigned int*)addr;
}
