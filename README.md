# IRIS Hardware Recruitments 2025 – Final Submission

This repository showcases the culmination of a month-long hardware track, where we explored CPU architecture, hardware-software interfaces, and bare-metal embedded systems. Spanning RISC-V CPU design, AXI-based IPs, and bare-metal OS development, this journey tested both our digital design fundamentals and system-level thinking.

---

## Overview of Tasks

### Task 1: RISC-V CPU (Single-Cycle & Pipelined)

We built a custom RISC-V processor in Verilog implementing:

- RV32I ISA subset: ADD, SUB, LW, SW, BEQ, ADDI, ORI, JAL, etc.
- Single-cycle implementation with custom control logic
- Custom instruction for counting trailing zeros

Pipelined version with:

- Instruction Fetch, Decode, Execute, Memory, Writeback stages
- Hazard detection and data forwarding

Testbenches were developed to validate instruction execution, and simulations were run using Icarus Verilog + GTKWave.

**Skills:** Datapath & control design, pipelining, instruction-level simulation

---

### Task 2: LFSR via AXI (Lite & Stream)

We developed an AXI-compliant LFSR (Linear Feedback Shift Register) as a custom IP core.

**AXI4-Lite interface:**
- Write seed/reset
- Start signal
- Read current pseudo-random value

**AXI4-Stream interface:**
- Continuous streaming of LFSR output

Integrated with Xilinx Vivado IP Integrator and verified using a Python-based AXI master testbench.

**Skills:** AXI protocol, IP core development, HDL-to-SoC integration, Stream protocol

---

### Task 3: Bare-Metal OS on Raspberry Pi 2

We implemented a mini OS kernel targeting ARMv7-A (Raspberry Pi 2B):

- UART driver using Mini UART (MMIO)
- EL1 to EL0 privilege switching
- SVC-based syscall mechanism
- MMU setup with 1MB section-based virtual memory
- User-space execution with hardware access restrictions

Tested fully on QEMU with clean console output via UART.

**Skills:** ARM exception levels, syscall design, memory protection, MMIO, low-level boot flow

---

## Directory Structure

```
.
├── task1_riscv/        # RISC-V CPU (single-cycle + pipelined)
├── task2_axi_lfsr/     # AXI-based LFSR (Lite + Stream)
├── task3_rpi_os/       # Bare-metal Raspberry Pi OS (UART, SVC, MMU)
├── makefile / scripts  # Per-task build automation
└── README.md           # You’re here
```

---

## Tech Stack

- Verilog HDL, SystemVerilog, ARM Assembly, C
- Icarus Verilog, Vivado, QEMU
- AXI4-Lite, AXI4-Stream, UART, MMU (ARMv7-A)

---

## Outcome

This repo reflects our end-to-end capabilities as a hardware enthusiast—from CPU design and bus protocols to memory protection and privilege separation. These tasks tested our ability to:

- Think from the microarchitecture level (RISC-V pipeline)
- Understand hardware-software co-design (AXI IPs)
- Manage bare-metal systems and ARM internals

---

## Author

**Mukul Paliwal**  
Second-Year Electrical Engineering, NITK  
IRIS Hardware Recruitments – April 2025
