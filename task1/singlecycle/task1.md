# Single-Cycle RISC-V Processor

## Overview
This project implements a **Single-Cycle RISC-V Processor** that supports a subset of the **RV32I** instruction set. The processor executes each instruction in a single clock cycle and is designed using Verilog.

## Supported Instructions
The processor supports the following instructions:

- **R-Type:** `ADD`, `SUB`, `AND`, `OR`, `SLL`, `SRL`, `XOR`
- **I-Type:** `ADDI`, `SLLI`, `LW`, `ORI`
- **S-Type:** `SW`
- **B-Type:** `BEQ`, `BGT`
- **J-Type:** `JAL`

## Project Structure
The project consists of multiple Verilog modules:

### 1. **Top Module** (`SingleCycleCPU.v`)
   - Connects all the components.
   - Implements the data path and control logic.

### 2. **Control Unit** (`Control.v`)
   - Generates control signals based on the opcode.

### 3. **ALU Control Unit** (`ALUCtrl.v`)
   - Decodes `funct3` and `funct7` to generate ALU operations.

### 4. **Arithmetic Logic Unit (ALU)** (`ALU.v`)
   - Executes arithmetic and logical operations.

### 5. **Program Counter (PC)** (`PC.v`)
   - Holds the address of the current instruction.

### 6. **Instruction Memory** (`InstructionMemory.v`)
   - Stores the program instructions.

### 7. **Data Memory** (`DataMemory.v`)
   - Stores data used in `LW` and `SW` instructions.

### 8. **Register File** (`Register.v`)
   - Stores register values (`x0` to `x31`).

### 9. **Immediate Generator** (`ImmGen.v`)
   - Extracts immediate values for `I`, `S`, `B`, `J`, and `U`-type instructions.

### 10. **Multiplexers** (`Mux2to1.v`)
   - Used for selecting between different inputs.

### 11. **Adder** (`Adder.v`)
   - Used for computing `PC + 4` and branch target addresses.

### 12. **Testbench** (`tb_riscv_sc.v`)
   - Verifies the functionality of the processor.

## Simulation & Testing
### Steps to Simulate:
1. **Compile the design:**
   ```bash
   iverilog -o tb_riscv_sc.vvp tb_riscv_sc.v SingleCycleCPU.v
   ```
2. **Run the simulation:**
   ```bash
   vvp tb_riscv_sc.vvp
   ```
3. **View the waveform (Optional):**
   ```bash
   gtkwave riscv_waveform.vcd
   ```

### Key Signals to Monitor:
- **Instruction Fetch:** `PC`, `inst`
- **Register File:** `rs1`, `rs2`, `rd`, `writeData`
- **ALU:** `ALUOp`, `ALUOut`
- **Memory Access:** `memRead`, `memWrite`, `readData`
- **Control Signals:** `regWrite`, `branch`, `ALUSrc`



## Future Enhancements
- Implement **pipeline architecture** for improved performance.
- Extend instruction support to include **full RV32I and M extensions**.

## Credits
Developed by **Mukul Paliwal** as part of **IRIS** recruitments. 🚀



