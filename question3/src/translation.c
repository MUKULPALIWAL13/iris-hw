#include "translation.h"
#include "peripherals/base.h"

#define SECTION_DESCRIPTOR        0x2
#define REGION_DEVICE             0x00000010
#define REGION_NORMAL             0x00001100
#define AP_PRIV_RW_USER_NO        0x01
#define AP_PRIV_RW_USER_RW        0x03
#define PAGE_TABLE_ENTRIES        4096

static unsigned int *ttb = (unsigned int *)TRANSLATION_TABLE_BASE;

void map_kernel_and_user_space() {
    for (int i = 0; i < PAGE_TABLE_ENTRIES; i++) {
        // Default mapping: privileged only
        ttb[i] = (i << 20) | REGION_NORMAL | (AP_PRIV_RW_USER_NO << 10) | SECTION_DESCRIPTOR;
    }

    // Map first 1 MB (code/data) as user-accessible
    ttb[0x000] = (0x000 << 20) | REGION_NORMAL | (AP_PRIV_RW_USER_RW << 10) | SECTION_DESCRIPTOR;

    // UART MMIO: privileged-only device memory
    unsigned int uart_index = UART_BASE >> 20;
    ttb[uart_index] = (uart_index << 20) | REGION_DEVICE | (AP_PRIV_RW_USER_NO << 10) | SECTION_DESCRIPTOR;
}

unsigned int *get_translation_table() {
    return ttb;
}
