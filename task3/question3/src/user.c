#include "user.h"
void user_mode_entry() {
    asm volatile("svc #0");  // Trigger syscall to print from kernel
    while (1);               // Stay here forever
}
