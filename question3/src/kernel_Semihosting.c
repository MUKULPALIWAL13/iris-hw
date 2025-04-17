#include "mm.h"
#include "translation.h"
#include "printf.h"

extern void switch_to_user_mode();

void kernel_main(void) {
    // Setup page tables with proper access control
    map_kernel_and_user_space();

    // Enable MMU
    mmu_init();

    // Initialize UART for printf
    printf_init();

    // Kernel prints
    printf("Hello from EL1 (Kernel Mode)\n");

    // Switch to EL0 and run user code
    switch_to_user_mode();

    // Should never return
    while (1);
}
