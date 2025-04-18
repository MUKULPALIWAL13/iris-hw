#include "printf.h"
void handle_syscall(unsigned int syscall_num) {
    if (syscall_num == 0) {
        printf("Hello from EL0 via syscall!\n");
    }
}