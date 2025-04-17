# 🧠 IRIS LABS Assignment III – Task 3 Submission

This repository contains solutions for **IRIS Labs Hardware Assignment III**, targeting **bare-metal development** on the Raspberry Pi 2B (ARMv7-A) using QEMU emulation.

> The assignment explores low-level UART communication, privilege-level separation, and memory management using the ARM MMU.

---

## 📁 Folder Structure

Each folder corresponds to a **specific task question** from the assignment:

### 🔹 [task1_uart_el1](./task1_uart_el1)
- Implements UART-based serial output using MMIO
- Runs entirely in **EL1** (privileged mode)
- Custom `printf()` implementation (no standard libraries)

### 🔹 [task2_uart_protection_el0](./task2_uart_protection_el0)
- Introduces **privilege separation**
- Transitions from **EL1 to EL0**
- Blocks direct UART access from EL0
- Uses **`svc`** (supervisor call) for indirect UART output

### 🔹 [task3_virtual_memory](./task3_virtual_memory)
- BONUS Task
- Sets up **virtual memory using the ARM MMU**
- Separates **kernel and user memory**
- Executes a user-mode program in a separate memory region
- UART remains **accessible only from EL1**

---

## 📄 Please Read the Subtask READMEs

👉 Each task folder has its **own `README.md`** explaining:
- Design and implementation choices
- Build and execution instructions
- Diagrams or debugging outputs (where relevant)

---

## 🧪 Platform Details

- **Board**: Raspberry Pi 2B (BCM2836)
- **Emulator**: QEMU
- **Toolchain**: `arm-none-eabi-gcc`

---

## 🛠️ General Build & Run (for each task)

Inside any task folder:
```sh
make
qemu-system-arm -M raspi2b -kernel kernel7.img -serial stdio -display none
```
> Some tasks may use `kernel8.img` depending on your linker script or memory map.

---

## 📚 References

- ARMv7-A Architecture Reference Manual
- BCM2836 SoC Datasheet
- IRIS Labs Assignment III PDF

---

## 👨‍💻 Author

- **MUKUL PALIWAL**
- *IRIS Labs – Hardware Assignment III*
