# RISC-V Control Signals & Execution Analysis

## (a) Control Signal Values for `beq`, `sw`, and `lw`

The following table lists the control signals for the `beq`, `sw`, and `lw` instructions. "x" denotes a **don't care** value.

| Signal   | `beq` (Branch) | `sw` (Store) | `lw` (Load) |
|----------|---------------|-------------|-------------|
| `RegWrite`  | 0  | 0  | 1  |
| `MemRead`   | 0  | 0  | 1  |
| `MemWrite`  | 0  | 1  | 0  |
| `MemtoReg`  | x  | x  | 1  |
| `ALUSrc`    | 0  | 1  | 1  |
| `Branch`    | 1  | 0  | 0  |
| `Jump`      | 0  | 0  | 0  |
| `ALUOp`     | 01 | 00 | 00 |
| `ImmSrc`    | 10 | 01 | 00 |

---

## (b) Execution of RISC-V Assembly Code

### **Given Code**
```assembly
loop:  slt x2, x0, x1      # x2 = (x0 < x1) ? 1 : 0
       beq x2, x0, DONE    # If x2 == 0, go to DONE
       addi x1, x1, -1     # x1 = x1 - 1
       addi x2, x2, 2      # x2 = x2 + 2
       j loop              # Jump back to loop
done:
