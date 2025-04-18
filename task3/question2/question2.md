# 🛡️ Task 2: Restrict UART Access from EL0

## 📜 Objective

Extend your bare-metal Raspberry Pi setup to support exception level control. This task ensures proper privilege separation by:

1. Switching from **EL1** (kernel mode) to **EL0** (user mode).
2. Preventing **direct UART access** from EL0.
3. Handling EL0 UART calls via **SVC (Supervisor Calls)**.
4. Triggering **controlled exceptions** or failures for unauthorized UART use.

---

## ✅ Checkpoints Achieved

- ✅ Ran code entirely in EL1 initially.
- ✅ Switched to EL0 (user mode) after system boot.
- ✅ Prevented direct access to UART from EL0.
- ⚠️ *Privileged mechanism (SVC handler) to access UART indirectly from EL0 not fully implemented.*

---

## 📦 File Structure Overview

```
├── include
│   ├── peripherals
│   │   ├── base.h             // Peripheral base addresses
│   │   ├── gpio.h             // GPIO controls
│   │   └── mini_uart.h        // UART register interface
│   ├── mini_uart.h           // UART APIs for kernel
│   ├── mm.h                  // Mode switching macros
│   ├── printf.h              // Custom printf declarations
│   ├── user.h                // User-space program declarations
│   └── utils.h               // Utility macros and helpers
├── output                    // Folder for QEMU test logs
├── src
│   ├── boot.S                // Entry point & stack setup
│   ├── kernel_Semihosting.c // 
│   ├── kernel.c.backup       // Backup
│   ├── linker.ld             // Linker script
│   ├── mini_uart.c           // UART initialization, TX, RX
│   ├── mm.S                  // Switch to EL0 from EL1
│   ├── printf.c              // Custom printf() (4-char strings only)
│   ├── privilege.S           // Mode-checking assembly
│   ├── svc_handler.S         // SVC handler for EL0 to EL1 syscall *(not functional)*
│   ├── user.c                // User program entry (user_main)
│   ├── utils.c               // Misc helpers
│   ├── utils.S               // Inline ASM helpers
│   └── vectors.S             // Exception vector table
```

---

## ⚙️ Working Principle

- System initializes in EL1.
- UART is initialized in `kernel_main()`.
- Control is passed to `user_main()` in EL0.
- Attempts to access UART directly from EL0 result in exceptions.
- *(Planned)* SVC handler in EL1 receives syscall for UART output.

> Note: The custom `printf()` only accepts strings of length *4*.

---

## 🖨️ Sample Output from UART Console

```
hello world
Direct call
User
Returned
Try switch 
MODE:19
hello world
Direct call
User
Returned
Try switch 
MODE:16
hello world
Direct call
User
Returned
Try switch 
MODE:23
hello world
Direct call
User
Returned
Try switch 
MODE:23
```

---

## 🔢 Mode Values Explained

- **MODE: 19** → EL1h (Handler mode, EL1)
- **MODE: 16** → EL0 (EL0)
- **MODE: 23** → EL1t (Thread mode, EL1 - typically Abort/Exception handling)

These prints help debug what privilege level the CPU is currently executing in during transitions or exception triggers.

---

## 🚀 Summary

This task enforced privilege separation in a bare-metal system using ARMv7-A architecture. Direct UART access from EL0 is successfully blocked. Although the syscall-based UART mechanism is outlined, the full SVC handler implementation is pending.

---
## 🙋‍♂️ Credits  
- **Testing**: QEMU on WSL2
- **This project is part of IRIS Hardware recruitments by MUKUL PALIWAL**

