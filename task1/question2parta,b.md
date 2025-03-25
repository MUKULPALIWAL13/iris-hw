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
assembly
loop:  slt x2, x0, x1      # x2 = (x0 < x1) ? 1 : 0
       beq x2, x0, DONE    # If x2 == 0, go to DONE
       addi x1, x1, -1     # x1 = x1 - 1
       addi x2, x2, 2      # x2 = x2 + 2
       j loop              # Jump back to loop
done:
so starting with x1 = 8 and x2 = 2
loop -- x0<x1 true so x2 = 1, no branching , x1 = 8-1 = 7 , x2 = 1 + 2 = 3 , back to loop
loop --  x0<x1 true so x2 = 1, no branching , x1 = 7-1 = 6 , x2 = 1 + 2 = 3 , back to loop
loop --  x0<x1 true so x2 = 1, no branching , x1 = 6-1 = 5 , x2 = 1 + 2 = 3 , back to loop
loop --  x0<x1 true so x2 = 1, no branching , x1 = 6-1 = 5 , x2 = 1 + 2 = 3 , back to loop
loop --  x0<x1 true so x2 = 1, no branching , x1 = 5-1 = 4 , x2 = 1 + 2 = 3 , back to loop
loop --  x0<x1 true so x2 = 1, no branching , x1 = 4-1 = 3 , x2 = 1 + 2 = 3 , back to loop
loop --  x0<x1 true so x2 = 1, no branching , x1 = 3-1 = 2 , x2 = 1 + 2 = 3 , back to loop
loop --  x0<x1 true so x2 = 1, no branching , x1 = 2-1 = 1 , x2 = 1 + 2 = 3 , back to loop
loop --  x0<x1 true so x2 = 1, no branching , x1 = 1-1 = 0 , x2 = 1 + 2 = 3 , back to loop
loop --  x0<x1 false so x2 = 0, branching, goes to done 
so finally x2 = 0 
### **Part c)**
New control signal added was ctz which was set high whenever it detects opcode 7'b1001011 , and genrates values regWrite = 1;  ALUOp = 2'b10;
then ALUcntrl is set to 1111 where a function is called to count number of trailing zeros and ALUOut is set equal to that number.

            
          








