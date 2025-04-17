extern void user_mode_entry(void);
void switch_to_user_mode() {
    asm volatile (
        "mov r0, #0\n"
        "msr cpsr_c, #0x10\n"     // Switch to User mode
        "bl user_mode_entry\n"
    );
}
