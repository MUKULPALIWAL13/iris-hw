`include "Mux2to1.v"
`include "Adder.v"
`include "fetch.v"
`include "decode.v"
`include "execute.v"
`include "memory_c.v"
`include "writeback.v"
`include "hazard.v"  // ✅ Hazard Unit

module pipelined_riscv(
    input clk,
    input rst
);

    // Fetch Cycle Wires
    wire [31:0] InstrD, PCD, PCPlus4D;

    // Decode Cycle Wires
    wire RegWriteE, ALUSrcE, MemWriteE, MemReadE, ResultSrcE, BranchE;
    wire [3:0] ALUControlE;
    wire [31:0] RD1_E, RD2_E, Imm_Ext_E;
    wire [4:0] RS1_E, RS2_E, RD_E;
    wire [31:0] PCE, PCPlus4E;

    // Execute Cycle Wires
    wire PCSrcE, RegWriteM, MemWriteM, MemReadM, ResultSrcM;
    wire [4:0] RD_M;
    wire [31:0] PCPlus4M, WriteDataM, ALU_ResultM;
    wire [31:0] PCTargetE;
    wire [1:0] ForwardAE, ForwardBE;  // ✅ Only Data Forwarding (Updated naming)

    // Memory Cycle Wires
    wire RegWriteW, ResultSrcW;
    wire [4:0] RD_W;
    wire [31:0] PCPlus4W, ALU_ResultW, ReadDataW;

    // Writeback Cycle Wire
    wire [31:0] ResultW;

    // FETCH STAGE
    fetch_cycle fetch_stage(
        .clk(clk),
        .rst(rst),
        .branchMuxSel(PCSrcE),      // PCSrcE decides branch or next instruction
        .branchTarget(PCTargetE),   // Target address if branch is taken
        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D)
    );

    // DECODE STAGE
    decode_cycle decode_stage(
        .clk(clk),
        .rst(rst),
        .RegWriteW(RegWriteW),
        .RDW(RD_W),
        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D),
        .ResultW(ResultW),
        .RegWriteE(RegWriteE),
        .ALUSrcE(ALUSrcE),
        .MemWriteE(MemWriteE),
        .MemReadE(MemReadE),
        .ResultSrcE(ResultSrcE),
        .BranchE(BranchE),
        .ALUControlE(ALUControlE),
        .RD1_E(RD1_E),
        .RD2_E(RD2_E),
        .Imm_Ext_E(Imm_Ext_E),
        .RD_E(RD_E),
        .PCE(PCE),
        .PCPlus4E(PCPlus4E),
        .RS1_E(RS1_E),
        .RS2_E(RS2_E)
    );

    // EXECUTE STAGE
    execute_cycle execute_stage(
        .clk(clk),
        .rst(rst),
        .RegWriteE(RegWriteE),
        .ALUSrcE(ALUSrcE),
        .MemWriteE(MemWriteE),
        .MemReadE(MemReadE),
        .ResultSrcE(ResultSrcE),
        .BranchE(BranchE),
        .ALUControlE(ALUControlE),
        .RD1_E(RD1_E),
        .RD2_E(RD2_E),
        .Imm_Ext_E(Imm_Ext_E),
        .RD_E(RD_E),
        .PCE(PCE),
        .PCPlus4E(PCPlus4E),
        .PCSrcE(PCSrcE),
        .PCTargetE(PCTargetE),
        .RegWriteM(RegWriteM),
        .MemWriteM(MemWriteM),
        .MemReadM(MemReadM),
        .ResultSrcM(ResultSrcM),
        .RD_M(RD_M),
        .PCPlus4M(PCPlus4M),
        .WriteDataM(WriteDataM),
        .ALU_ResultM(ALU_ResultM),
        .ResultW(ResultW),
        .ForwardA_E(ForwardAE),  // ✅ Data Forwarding
        .ForwardB_E(ForwardBE)   // ✅ Data Forwarding
    );

    // MEMORY STAGE
    memory_cycle memory_stage(
        .clk(clk),
        .rst(rst),
        .RegWriteM(RegWriteM),
        .MemWriteM(MemWriteM),
        .MemReadM(MemReadM),
        .ResultSrcM(ResultSrcM),
        .RD_M(RD_M),
        .PCPlus4M(PCPlus4M),
        .WriteDataM(WriteDataM),
        .ALU_ResultM(ALU_ResultM),
        .RegWriteW(RegWriteW),
        .ResultSrcW(ResultSrcW),
        .RD_W(RD_W),
        .PCPlus4W(PCPlus4W),
        .ALU_ResultW(ALU_ResultW),
        .ReadDataW(ReadDataW)
    );

    // WRITEBACK STAGE
    writeback_cycle writeback_stage(
        .clk(clk),
        .rst(rst),
        .ResultSrcW(ResultSrcW),
        .PCPlus4W(PCPlus4W),
        .ALU_ResultW(ALU_ResultW),
        .ReadDataW(ReadDataW),
        .ResultW(ResultW)
    );

    // ✅ HAZARD UNIT (Only Data Hazard Handling)
    hazard_unit hazard_unit_inst (
        .rst(rst),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),
        .RD_M(RD_M),
        .RD_W(RD_W),
        .Rs1_E(RS1_E),
        .Rs2_E(RS2_E),
        .ForwardAE(ForwardAE),  // ✅ Updated naming
        .ForwardBE(ForwardBE)   // ✅ Updated naming
    );

endmodule
