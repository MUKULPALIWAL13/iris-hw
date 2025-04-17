#include "pages.h"
#include "peripherals/base.h"
#define PAGE_TABLE_BASE 0x4000
// Memory attributes and section descriptor
#define SECTION_DESCRIPTOR    0x2
#define SECTION_ADDR_MASK     0xFFF00000
#define REGION_STRONGLY_ORDERED  0x00000000
#define REGION_DEVICE            0x00000010
#define REGION_NORMAL            0x00001100

#define AP_PRIV_RW_USER_NO   0x01
#define AP_PRIV_RW_USER_RW   0x03

#define PAGE_TABLE_ENTRIES 4096

static unsigned int *ttb = (unsigned int *)PAGE_TABLE_BASE;

void setup_identity_mapping() {
    for (int i = 0; i < PAGE_TABLE_ENTRIES; i++) {
        // Map as privileged-only by default
        ttb[i] = (i << 20) | REGION_STRONGLY_ORDERED | (AP_PRIV_RW_USER_NO << 10) | SECTION_DESCRIPTOR;
    }

    // Example: identity-map 0x00000000–0x00100000 as user-accessible code/data
    ttb[0x000] = (0x000 << 20) | REGION_NORMAL | (AP_PRIV_RW_USER_RW << 10) | SECTION_DESCRIPTOR;

    // UART protected (to be set by mmu.c if needed)
}

unsigned int *get_page_table_base() {
    return ttb;
}
