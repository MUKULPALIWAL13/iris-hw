module Control (
    input [6:0] opcode,
    output reg branch, memRead, memtoReg, memWrite, ALUSrc, regWrite, ctz,
    output reg [1:0] ALUOp
);

always @(*) begin
    // Default values
    {branch, memRead, memtoReg, memWrite, ALUSrc, regWrite, ctz, ALUOp} = 9'b000000000;

    case (opcode)
        7'b0110011: begin  // R-type
            regWrite = 1;
            ALUOp = 2'b10;
        end
        7'b0010011: begin  // I-type (ADDI, ORI, SLLI, etc.)
            regWrite = 1;
            ALUSrc = 1;
            ALUOp = 2'b00;
        end
        7'b0000011: begin  // Load (LW)
            regWrite = 1;
            memRead = 1;
            memtoReg = 1;
            ALUSrc = 1;
            ALUOp = 2'b00;
        end
        7'b0100011: begin  // Store (SW)
            memWrite = 1;
            ALUSrc = 1;
            ALUOp = 2'b00;
        end
        7'b1100011: begin  // Branch (BEQ, BNE)
            branch = 1;
            ALUOp = 2'b01;
        end
        7'b1001011: begin  // Custom instruction (CTZ)
            regWrite = 1;
            ctz = 1;
            ALUOp = 2'b10;
        end
    endcase
end

endmodule
