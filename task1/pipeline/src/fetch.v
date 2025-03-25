`include "PC.v"
// `include "Adder.v"
`include "InstructionMemory.v"
// `include "Mux2to1.v"

module fetch_cycle(clk, rst, branchMuxSel, branchTarget, InstrD, PCD, PCPlus4D);

    // Declare inputs & outputs
    input clk, rst;
    input branchMuxSel;
    input [31:0] branchTarget;
    output [31:0] InstrD;
    output [31:0] PCD, PCPlus4D;

    // Declaring interim wires
    wire [31:0] pco, pci, nextPC;
    wire [31:0] inst;

    // Declaration of Register
    reg [31:0] inst_reg;
    reg [31:0] pco_reg, nextPC_reg;

    // Initiation of Modules
    // PC Mux
    Mux2to1 #(.size(32)) m_Mux_PC(
        .sel(branchMuxSel),
        .s0(nextPC),
        .s1(branchTarget),
        .out(pci)
    );

    // PC Counter
    PC m_PC(
        .clk(clk),
        .rst(rst),
        .pc_i(pci),
        .pc_o(pco)
    );

    // Instruction Memory
    InstructionMemory m_InstMem(
        .readAddr(pco),
        .inst(inst)
    );

    // PC Adder
    Adder m_Adder_1(
        .a(pco),
        .b(32'd4),
        .sum(nextPC)
    );

    // Fetch Cycle Register Logic
    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            inst_reg  <= 32'h00000000;
            pco_reg   <= 32'h00000000;
            nextPC_reg <= 32'h00000000;
        end else begin
            inst_reg  <= inst;
            pco_reg   <= pco;
            nextPC_reg <= nextPC;
        end
    end

    // Assigning Registers Value to the Output ports
    assign InstrD = (rst == 1'b0) ? 32'h00000000 : inst_reg;
    assign PCD = (rst == 1'b0) ? 32'h00000000 : pco_reg;
    assign PCPlus4D = (rst == 1'b0) ? 32'h00000000 : nextPC_reg;

endmodule
