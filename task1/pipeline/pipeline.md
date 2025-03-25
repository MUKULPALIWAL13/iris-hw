# Pipelined RISC-V Processor

## Overview
This project implements a **5-stage pipelined RISC-V processor** supporting a subset of the **RV32I** instruction set. The processor is designed in **Verilog** and simulates execution with a testbench.

## Features
- Implements **5 pipeline stages**:  
  1. **Fetch (IF)**
  2. **Decode (ID)**
  3. **Execute (EX)**
  4. **Memory Access (MEM)**
  5. **Write Back (WB)**
- Supports **data forwarding** to handle data hazards.
- Can execute **basic arithmetic, logical, memory, and branch instructions**.
- Memory is implemented separately with a provided `.dat` file.
- Written in **Verilog** with testbench validation.

## Architecture

### Pipeline Stages
1. **Instruction Fetch (IF)**
   - Fetches the instruction from memory.
   - Updates the **Program Counter (PC)**.

2. **Instruction Decode (ID)**
   - Decodes the instruction fields.
   - Reads registers.
   - Generates control signals.

3. **Execute (EX)**
   - Performs ALU operations.
   - Computes branch targets.

4. **Memory Access (MEM)**
   - Reads/writes data memory for load/store instructions.

5. **Write Back (WB)**
   - Writes the result back to registers.

---

## Files & Modules
- **pipelinetop.v**: Top module connecting all pipeline stages.
- **fetch.v**: Instruction Fetch (IF) stage.
- **decode.v**: Instruction Decode (ID) stage.
- **execute.v**: Execute (EX) stage.
- **memory_c.v**: Memory Access (MEM) stage.
- **writeback.v**: Write Back (WB) stage.
- **hazard.v**: Handles data hazards using forwarding.
- **controlnew.v**: Generates control signals based on opcode.
- **immgen.v**: Immediate generator for I, S, B, U, and J-type instructions.
- **alu.v**: ALU implementation.
- **mux.v**: Multiplexer module.
- **register.v**: Register file implementation.
- **tb_pipeline.v**: Testbench for pipeline verification.

---

## How to Run Simulation
To run the simulation, compile all the Verilog files together and run the simulation. Waveforms can be viewed using GTKWave for debugging purposes. You can create your own simulation commands based on your environment.

---

## Pipeline Hazard Handling
- **Data Hazards**: Resolved using a forwarding unit.
- **Control Hazards**: Currently not implemented (no branch prediction).

---

## Testing & Debugging
The testbench initializes the processor and loads instructions from a `.dat` file. Use a waveform viewer to monitor key signals such as PC values, register values, ALU outputs, memory states, and control signals.

---

## Future Improvements
- Implement control hazard handling (e.g., branch prediction and flushing).
- Add support for more RISC-V instructions.
- Optimize for higher clock speeds and efficiency.

---

## Contributors
***Mukul Paliwal***

---
