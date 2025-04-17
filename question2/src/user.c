#include "mini_uart.h"
extern void* svc_handler;
void user_main() {
    // // User function message using chunks
    char user1[] = {'U', 's', 'e', 'r'};
    char user2[] = {'\n'};
    
    for (int i = 0; i < 4; i++) uart_send(user1[i]);
    for (int i = 0; i < 1; i++) uart_send(user2[i]);
    
   
    // // Return to caller
   
   return;
}

// #include "mini_uart.h"
// void user_main(void) {
//     // Put a value in r0 (first parameter)
//     // asm volatile("mov r0, #42");
    
//     // Call SVC handler
//     asm volatile("svc #0");
    
//     // Loop forever
//     while(1) {}
// }

//     // // Define message in chunks
//     // char part1[] = {'U', 's', 'e', 'r', ' '};
//     // char part2[] = {'v', 'i', 'a', ' '};
//     // char part3[] = {'S', 'V', 'C', '\n'};
    
//     // // Use SVC to print instead of direct UART access
//     // // First chunk
//     // asm volatile("mov r0, %0" : : "r" (part1));
//     // asm volatile("mov r1, %0" : : "r" (5));  // Length of part1
//     // asm volatile("svc #0");
    
//     // // Second chunk
//     // asm volatile("mov r0, %0" : : "r" (part2));
//     // asm volatile("mov r1, %0" : : "r" (4));  // Length of part2
//     // asm volatile("svc #0");
    
//     // // Third chunk
//     // asm volatile("mov r0, %0" : : "r" (part3));
//     // asm volatile("mov r1, %0" : : "r" (4));  // Length of part3
//     // asm volatile("svc #0");
    
//     // // Loop forever
//     // while(1) {}
