#include "mm.h"
#include "peripherals/base.h"

#define TTB_BASE  0x4000
#define SECTION_DESCRIPTOR    0x2
#define SECTION_ADDR_MASK     0xFFF00000
#define REGION_STRONGLY_ORDERED  0x00000000
#define REGION_DEVICE            0x00000010
#define REGION_NORMAL            0x00001100
#define AP_NO_ACCESS         0x00
#define AP_PRIV_RW_USER_NO   0x01
#define AP_PRIV_RW_USER_RO   0x02
#define AP_PRIV_RW_USER_RW   0x03

#include "translation.h"

void mmu_init(void) {
    map_kernel_and_user_space();

    unsigned int *ttb = get_translation_table();
    asm volatile("mcr p15, 0, %[ttb], c2, c0, 0" :: [ttb] "r"(ttb));
    asm volatile("mcr p15, 0, %[dacr], c3, c0, 0" :: [dacr] "r"(0x55555555));

    unsigned int sctlr;
    asm volatile("mrc p15, 0, %[sctlr], c1, c0, 0" : [sctlr] "=r"(sctlr));
    sctlr |= (1 << 0);  // Enable MMU
    asm volatile("mcr p15, 0, %[sctlr], c1, c0, 0" :: [sctlr] "r"(sctlr));
}

void protect_uart_memory(void) {
    unsigned int uart_index = (UART_BASE >> 20);
    unsigned int* ttb = (unsigned int*)TTB_BASE;
    ttb[uart_index] = (uart_index << 20) | REGION_DEVICE | (AP_PRIV_RW_USER_NO << 10) | SECTION_DESCRIPTOR;
    asm volatile("mcr p15, 0, r0, c8, c7, 0");
}
