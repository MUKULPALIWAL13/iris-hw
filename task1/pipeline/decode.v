
`include "controlnew.v"
`include "Register.v"
`include "ImmGen.v"
module decode_cycle(
    input clk, rst, RegWriteW,
    input [4:0] RDW,
    input [31:0] InstrD, PCD, PCPlus4D, ResultW,
    output RegWriteE, ALUSrcE, MemWriteE, MemReadE, ResultSrcE, BranchE,
    output [3:0] ALUControlE,
    output [31:0] RD1_E, RD2_E, Imm_Ext_E,
    output [4:0] RS1_E, RS2_E, RD_E,
    output [31:0] PCE, PCPlus4E
);

    // Declare Interim Wires
    wire RegWriteD, ALUSrcD, MemWriteD, MemReadD, ResultSrcD, BranchD;
    wire [3:0] ALUControlD;
    wire [31:0] RD1_D, RD2_D, Imm_Ext_D;

    // Declaration of Interim Registers
    reg RegWriteD_r, ALUSrcD_r, MemWriteD_r, MemReadD_r, ResultSrcD_r, BranchD_r;
    reg [3:0] ALUControlD_r;
    reg [31:0] RD1_D_r, RD2_D_r, Imm_Ext_D_r;
    reg [4:0] RD_D_r, RS1_D_r, RS2_D_r;
    reg [31:0] PCD_r, PCPlus4D_r;

    // Control Unit
    controlnew control (
        .opcode(InstrD[6:0]), 
        .funct3(InstrD[14:12]), 
        .funct7(InstrD[31:25]), 
        .branch(BranchD), 
        .memRead(MemReadD),  // ✅ **Fixed: Added memRead for Load instructions**
        .memtoReg(ResultSrcD), 
        .memWrite(MemWriteD), 
        .ALUSrc(ALUSrcD), 
        .regWrite(RegWriteD), 
        .ALUCtl(ALUControlD)
    );

    // Register File
    Register m_Register (
        .clk(clk),
        .rst(rst),
        .regWrite(RegWriteW),
        .readReg1(InstrD[19:15]),
        .readReg2(InstrD[24:20]),
        .writeReg(RDW),
        .writeData(ResultW),
        .readData1(RD1_D),
        .readData2(RD2_D)
    );

    // Sign Extension
    ImmGen m_ImmGen (
        .inst(InstrD),
        .imm(Imm_Ext_D)
    );

    // Register Logic
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            RegWriteD_r <= 1'b0;
            ALUSrcD_r <= 1'b0;
            MemWriteD_r <= 1'b0;
            MemReadD_r <= 1'b0;  // ✅ **Fixed: Added MemReadD_r**
            ResultSrcD_r <= 1'b0;
            BranchD_r <= 1'b0;
            ALUControlD_r <= 3'b000;
            RD1_D_r <= 32'h00000000;
            RD2_D_r <= 32'h00000000;
            Imm_Ext_D_r <= 32'h00000000;
            RD_D_r <= 5'h00;
            PCD_r <= 32'h00000000;
            PCPlus4D_r <= 32'h00000000;
            RS1_D_r <= 5'h00;
            RS2_D_r <= 5'h00;
        end else begin
            RegWriteD_r <= RegWriteD;
            ALUSrcD_r <= ALUSrcD;
            MemWriteD_r <= MemWriteD;
            MemReadD_r <= MemReadD;  // ✅ **Fixed: Store MemReadD**
            ResultSrcD_r <= ResultSrcD;
            BranchD_r <= BranchD;
            ALUControlD_r <= ALUControlD;
            RD1_D_r <= RD1_D;
            RD2_D_r <= RD2_D;
            Imm_Ext_D_r <= Imm_Ext_D;
            RD_D_r <= InstrD[11:7];
            PCD_r <= PCD;
            PCPlus4D_r <= PCPlus4D;
            RS1_D_r <= InstrD[19:15];
            RS2_D_r <= InstrD[24:20];
        end
    end

    // Output Assignments
    assign RegWriteE = RegWriteD_r;
    assign ALUSrcE = ALUSrcD_r;
    assign MemWriteE = MemWriteD_r;
    assign MemReadE = MemReadD_r;  // ✅ **Fixed: Forward MemReadE**
    assign ResultSrcE = ResultSrcD_r;
    assign BranchE = BranchD_r;
    assign ALUControlE = ALUControlD_r;
    assign RD1_E = RD1_D_r;
    assign RD2_E = RD2_D_r;
    assign Imm_Ext_E = Imm_Ext_D_r;
    assign RD_E = RD_D_r;
    assign PCE = PCD_r;
    assign PCPlus4E = PCPlus4D_r;
    assign RS1_E = RS1_D_r;
    assign RS2_E = RS2_D_r;

endmodule
