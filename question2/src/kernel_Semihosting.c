#include "mini_uart.h"
#include "user.h"
#include "utils.h"
extern void* vectors;
extern void* svc_handler;

void check_mode() {
    unsigned int mode;
    asm volatile("mrs %0, cpsr" : "=r"(mode));
    mode &= 0x1F;  // Mask to get mode bits only

    // Print "MODE:"
    uart_send('M');
    uart_send('O');
    uart_send('D');
    uart_send('E');
    uart_send(':');

    // Convert decimal to ASCII (2 digits)
    uart_send('0' + (mode / 10));   // tens place
    uart_send('0' + (mode % 10));   // units place
    uart_send('\n');
}

void kernel_main(void) {
    uart_init();
    
    // Output "hello world" using 4-character chunks
    char part1[] = {'h', 'e', 'l', 'l'};
    char part2[] = {'o', ' ', 'w', 'o'};
    char part3[] = {'r', 'l', 'd', '\n'};

    for (int i = 0; i < 4; i++) uart_send(part1[i]);
    for (int i = 0; i < 4; i++) uart_send(part2[i]);
    for (int i = 0; i < 4; i++) uart_send(part3[i]);

    // Test 1: Direct call message
    char test1[] = {'D', 'i', 'r', 'e'};
    char test2[] = { 'c', 't',' ', 'c',};
    char test3[] = { 'a', 'l', 'l','\n'};
  
    
    for (int i = 0; i < 4; i++) uart_send(test1[i]);
    for (int i = 0; i < 4; i++) uart_send(test2[i]);
    for (int i = 0; i < 4; i++) uart_send(test3[i]);
    
    // Call user_main directly (still in kernel mode)
    user_main();
    
    // If we get here, user_main returned
    char ret1[] = {'R', 'e', 't', 'u'};
    char ret2[] = {'r', 'n', 'e', 'd'};
    char ret3[] = {'\n'};
    
    for (int i = 0; i < 4; i++) uart_send(ret1[i]);
    for (int i = 0; i < 4; i++) uart_send(ret2[i]);
    for (int i = 0; i < 1; i++) uart_send(ret3[i]);

    // Test 2: Now try the mode switch
    char sw1[] = {'T', 'r', 'y', ' '};
    char sw2[] = {'s', 'w', 'i', 't'};
    char sw3[] = {'c', 'h',' ', '\n'};
    
    for (int i = 0; i < 4; i++) uart_send(sw1[i]);
    for (int i = 0; i < 4; i++) uart_send(sw2[i]);
    for (int i = 0; i < 4; i++) uart_send(sw3[i]);
    // delay(150);
    // Switch to user mode
    check_mode();
    switch_to_el0(user_main);
    check_mode();

    // We should never reach here if the switch works properly
    char fail1[] = {'F', 'a', 'i', 'l'};
    char fail2[] = {'e', 'd', '\n'};
    
    for (int i = 0; i < 4; i++) uart_send(fail1[i]);
    for (int i = 0; i < 3; i++) uart_send(fail2[i]);
    
     
}
// void kernel_main(void) {
//     uart_init();
//     unsigned int vector_table_addr = (unsigned int)&vectors;
//     asm volatile("mcr p15, 0, %0, c12, c0, 0" : : "r" (vector_table_addr));
//     // Output "hello world" using chunks
//     char part1[] = {'h', 'e', 'l', 'l'};
//     char part2[] = {'o', ' ', 'w', 'o'};
//     char part3[] = {'r', 'l', 'd', '\n'};

//     for (int i = 0; i < 4; i++) uart_send(part1[i]);
//     for (int i = 0; i < 4; i++) uart_send(part2[i]);
//     for (int i = 0; i < 4; i++) uart_send(part3[i]);

//     // Try direct SVC from kernel mode to see if that works
//     char test1[] = {'T', 'r', 'y', ' '};
//     char test2[] = {'S', 'V', 'C', '\n'};
    
//     for (int i = 0; i < 4; i++) uart_send(test1[i]);
//     for (int i = 0; i < 4; i++) uart_send(test2[i]);
   
    
//     // Call SVC directly from kernel mode
//     asm volatile("svc #0");
    
//     // If we get here, SVC worked in kernel mode
//     char worked[] = {'S', 'V', 'C', ' ', 'O', 'K', '\n'};
//     for (int i = 0; i < 7; i++) uart_send(worked[i]);
    
//     // Now loop forever
//     while(1) {}
// }
// // Set up the vector table base address
// void init_vectors(void) {
//     // Point to our vector table
//     unsigned int vector_table_addr = (unsigned int)&vectors;
    
//     // Set VBAR (Vector Base Address Register)
//     asm volatile("mcr p15, 0, %0, c12, c0, 0" : : "r" (vector_table_addr));
// }