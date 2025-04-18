# 🧵 Bare-Metal Raspberry Pi OS – ARMv7-A (Raspberry Pi 2 Model B)

This repository contains a set of **bare-metal kernels** targeting the **Raspberry Pi 2B**, demonstrating key low-level system concepts on **ARMv7-A architecture**. The code is tested using **QEMU emulation** and focuses on:

- ✅ UART-based serial communication  
- ✅ Privilege level control using EL1 and EL0  
- ✅ Exception handling via software interrupts (SVC)  
- ✅ Memory management with MMU and section-based virtual memory  

---

## ✨ Features

- MMIO-based UART driver using `mini_uart`
- Custom `printf()` implementation (fixed 4-character chunk prints)
- EL1 ↔ EL0 privilege switching and syscall mechanism
- Virtual memory setup using MMU (1MB section mapping)
- User program execution in EL0 with syscall access only
- Strict UART access control (allowed only via EL1)

---

## 📌 Task Summaries

### ✅ Task 1 – UART Serial Output in EL1

- Initializes the UART0 using MMIO
- Runs the entire kernel in **EL1** (privileged mode)
- Sends `"Hello World\n"` through UART using a custom `uart_printf()` function
- Accepts input from user and echoes it back over UART

**Key Files:**
- `boot.S` – Initializes stack and jumps to `kernel_main`
- `mini_uart.c` – UART initialization and character send/receive
- `printf.c` – 4-character fixed-size UART print
- `kernel_Semihosting.c` – Calls UART init and prints message

---

### ✅ Task 2 – Privilege Separation and Syscall Entry

- Switches from EL1 to EL0 after boot
- Prevents direct access to MMIO (UART) from EL0
- Sets up exception vector and handles illegal access gracefully
- Outlines syscall interface using `svc`, though partial

**Key Files:**
- `mm.S` – Mode switch from EL1 to EL0
- `svc_handler.S` – Basic SVC trap (not fully implemented)
- `privilege.S` – Mode checking helpers
- `user.c` – User-mode program attempting UART access

---

### ✅ Task 3 – MMU & Virtual Memory

- Initializes MMU using CP15 system registers
- Creates 1MB-section page tables
- Restricts UART access to EL1 by memory attribute
- EL0 makes a syscall via `svc #0`, routed to EL1 handler
- Demonstrates syscall-based message printing from EL0

**Key Files:**
- `mmu.c` / `translation.c` – Sets up and enables MMU
- `svc_handler.S`, `svc.c` – SVC dispatcher and syscall logic
- `kernel.c` – Maps memory, enables MMU, and transfers control to EL0
- `user.c` – EL0 code triggering syscall

---

## 🛠️ Build Instructions

Ensure you have the `arm-none-eabi` toolchain installed.

```sh
make
```

This will generate `kernel7.img` (or `kernel8.img` depending on entry file) for each stage.

---

## ▶️ Run with QEMU

Run using QEMU emulating Raspberry Pi 2 Model B:

```sh
qemu-system-arm -M raspi2b -kernel kernel7.img -serial stdio -display none
```

> Output is shown via standard I/O in the terminal.

---

## 🗂️ Repository Structure

```
.
├── include/           # Header files: MMIO, UART, mode switching, etc.
├── src/               # Source files for kernel, UART, SVC, MMU
├── output/            # (Optional) Debug/test logs
├── linker.ld          # Linker script defining memory layout
├── makefile           # Build rules
├── kernel7.img        # Final binary to be loaded in QEMU
└── README.md          # Project documentation (this file)
```

---

## 💡 Development Highlights

- Written fully in **C and ARM Assembly**
- No dependency on standard C library or OS
- Demonstrates core OS kernel responsibilities from scratch
- Focuses on **security** via controlled hardware access

---

## 👨‍💻 Author

**Mukul Paliwal**  
As part of the **IRIS Hardware Recruitments 2025**  
Tested on **QEMU** with **WSL2**
