`include "Register.v"
`include "InstructionMemory.v"
`include "PC.v"
`include "Mux2to1.v"
`include "ShiftLeftOne.v"
`include "DataMemory.v"
`include "ALUCtrl.v"
`include "Control.v"
`include "ALU.v"
`include "ImmGen.v"
`include "Adder.v"

module SingleCycleCPU (
    input clk,
    input start
);

// Internal Wires
wire [31:0] pci, pco, inst;
wire branch, memread, memtoreg, memwrite, regwrite, ALUsrc, zero,ctz;
wire [1:0] ALUop;
wire [31:0] rs1, rs2, imm, B, ALUOut, readata, writedata;
wire [3:0] ALUctl;
wire branchMuxSel;
wire [31:0] branchOffset, branchTarget, nextPC;

// ✅ Program Counter (PC)
PC m_PC(
    .clk(clk),
    .rst(start),
    .pc_i(pci),
    .pc_o(pco)
);

// ✅ Instruction Fetch
InstructionMemory m_InstMem(
    .readAddr(pco),
    .inst(inst)
);

// ✅ Control Unit
Control m_Control(
    .opcode(inst[6:0]),
    .branch(branch),
    .memRead(memread),
    .memtoReg(memtoreg),
    .ALUOp(ALUop),
    .memWrite(memwrite),
    .ALUSrc(ALUsrc),
    .regWrite(regwrite),
    .ctz(ctz)
);

// ✅ Register File
Register m_Register(
    .clk(clk),
    .rst(start),
    .regWrite(regwrite),
    .readReg1(inst[19:15]),
    .readReg2(inst[24:20]),
    .writeReg(inst[11:7]),
    .writeData(writedata),
    .readData1(rs1),
    .readData2(rs2)
);

// ✅ Immediate Generator (ImmGen)
ImmGen m_ImmGen(
    .inst(inst),
    .imm(imm)
);

// ✅ ALU Control
ALUCtrl m_ALUCtrl(
    .ALUOp(ALUop),
    .ctz(ctz),
    .funct7(inst[30]),
    .funct3(inst[14:12]),
    .ALUCtl(ALUctl)
);

// ✅ ALU Source MUX
Mux2to1 #(.size(32)) m_Mux_ALU(
    .sel(ALUsrc),
    .s0(rs2),
    .s1(imm),
    .out(B)
);

// ✅ ALU Execution
ALU m_ALU(
    .ALUCtl(ALUctl),
    .A(rs1),
    .B(B),
    .ALUOut(ALUOut),
    .zero(zero)
);

// ✅ Shift Left 1 for Branch Offset Calculation
// ShiftLeftOne m_ShiftLeftOne(
//     .i(imm),
//     .o(branchOffset)
// );

// ✅ Branch Target Calculation
Adder m_Adder_2(
    .a((pco)),  
    .b(imm),
    .sum(branchTarget)
);

// ✅ PC MUX
assign branchMuxSel = (branch & zero) | (inst[6:0] == 7'b1101111); // Also handle JAL
Mux2to1 #(.size(32)) m_Mux_PC(
    .sel(branchMuxSel),
    .s0(nextPC),
    .s1(branchTarget),
    .out(pci)
);

// ✅ PC + 4 Calculation
Adder m_Adder_1(
    .a(pco),
    .b(32'd4),
    .sum(nextPC)
);

// ✅ Data Memory
DataMemory m_DataMemory(
    .rst(start),
    .clk(clk),
    .memWrite(memwrite),
    .memRead(memread),
    .address(ALUOut),
    .writeData(rs2),
    .readData(readata)
);

// ✅ Write Back MUX
Mux2to1 #(.size(32)) m_Mux_WriteData(
    .sel(memtoreg),
    .s0(ALUOut),
    .s1(readata),
    .out(writedata)
);

endmodule
