# 🧠 Task 3 – Virtual Memory and User Program Execution (Bare-metal on Raspberry Pi 2B)

This project demonstrates a **bare-metal OS kernel** on **Raspberry Pi 2B (ARMv7-A)** that sets up **virtual memory using the MMU**, enforces **privilege-level separation**, and executes a **user-mode program** via `svc` system calls.

> ⚠️ **Note:** This is a work-in-progress prototype. While MMU setup and memory protection are implemented, full user/kernel isolation and exception handling aren't 100% production-stable.

---

## 🎯 Objectives Covered

- MMU initialization and activation
- Virtual memory using section-based page tables (1 MB granularity)
- Kernel vs User memory separation
- MMIO isolation (UART accessible only in EL1)
- `svc #0` syscall mechanism from EL0 to EL1

---

## 🧩 Component Descriptions

### 🔐 MMU (`mmu.c`, `mmu.h`)
- Initializes MMU using **CP15 control registers**
- Sets up **TTBR0**, **DACR**, and enables the MMU via **SCTLR**
- Integrates with `translation.c` to use a generated page table

### 🧭 Translation Table Setup (`translation.c`, `translation.h`)
- Creates a page table at **physical address 0x4000**
- Memory Regions:
  - **User-accessible**: `0x00000000 – 0x00100000`
  - **Privileged MMIO (UART)**: `0x3F215000`
- Memory Attributes:
  - `REGION_NORMAL` for RAM
  - `REGION_DEVICE` for peripherals
  - `AP_PRIV_RW_USER_RW` for user RAM
  - `AP_PRIV_RW_USER_NO` for kernel and MMIO

### 🧵 Kernel Entry (`kernel.c`)
- Calls `map_kernel_and_user_space()`
- Enables MMU
- Prints `"Hello from EL1"`
- Switches to EL0 using `switch_to_user_mode()`

### 👤 User Program (`user.c`)
- Runs in EL0
- Triggers syscall using `svc #0`

### 🛠️ Syscall Handling
- `svc_handler.S`: Handles exceptions and calls `handle_syscall()`
- `svc.c`: Defines syscall logic → prints `"Hello from EL0 via syscall!"`

---

## ⚠️ Current Limitations

- No multi-level page tables (flat 1MB sections only)
- No virtual memory allocation
- No dynamic exception relocation
- EL0 isolation not tested under malicious input

---

## 🧪 How to Test

1. **Build** using `arm-none-eabi-gcc`
2. **Run** using QEMU:

*Example command:*
```
qemu-system-arm -M raspi2b -kernel kernel7.img -serial stdio -display none
```

### ✅ Expected Output
```
Hello from EL1
Hello from EL0 via syscall!
```

---

## 📁 Project File Overview

| File                  | Description                                |
|-----------------------|--------------------------------------------|
| `mmu.c`, `mmu.h`      | MMU control setup                          |
| `translation.c`, `translation.h` | Page table initialization       |
| `kernel.c`            | EL1 startup and transition to EL0          |
| `user.c`              | User-mode program logic                    |
| `svc_handler.S`       | SVC trap and dispatcher                    |
| `svc.c`               | Syscall service logic                      |
| `vectors.S`           | Exception vector table                     |
| `mini_uart.c`         | UART initialization and putc               |
| `utils.c`, `utils.h`  | Low-level helpers (`put32`, `get32`, etc.) |

---

## 💻 Target Platform

- **Board**: Raspberry Pi 2B (BCM2836)
- **UART MMIO Address**: `0x3F215000`

---

## 📚 References

- ARMv7-A Architecture Reference Manual
- BCM2836 SoC Datasheet
- IRIS Labs Assignment III

---

## 🚧 Status

**Prototype** – Partial features functional, system under development.

---

## 👨‍💻 Author

- **Name**: **MUKUL PALIWAL**
- **Course**: *IRIS Labs Hardware Assignment III – Task 3*
