module ALUCtrl (
    input [1:0] ALUOp,
    input funct7,
    input ctz,
    input [2:0] funct3,
    output reg [3:0] ALUCtl
);

always @(*) begin
    case (ALUOp)
        2'b00: begin  // Load, Store, ADDI
            if (funct3 == 3'b000)
                ALUCtl = 4'b0000; // ADD
            else if (funct3 == 3'b010)
                ALUCtl = 4'b1001; // SLTI
            else
                ALUCtl = 4'b1111; // Default (NOP)
        end
        
        2'b01: begin
                  ALUCtl = 4'b1010; // Branch Instructions (BEQ, BNE)
        end

        2'b10: begin
            case (funct3)
                3'b000: ALUCtl = (funct7) ? 4'b0001 : 4'b0000; // SUB (funct7=1) or ADD (funct7=0)
                3'b001: ALUCtl = 4'b0101; // SLL (Shift Left Logical)
                3'b010: ALUCtl = 4'b1000; // SLT (Set Less Than)
                3'b011: ALUCtl = 4'b1001; // SLTU (Set Less Than Unsigned)
                3'b100: ALUCtl = 4'b0100; // XOR
                3'b101: ALUCtl = (funct7) ? 4'b0111 : 4'b0110; // SRA (funct7=1) or SRL (funct7=0)
                3'b110: ALUCtl = 4'b0011; // OR
                3'b111: begin
                    if (funct7 && ctz)
                        ALUCtl = 4'b1111; // CTZ (Custom Instruction)
                    else
                        ALUCtl = 4'b0010; // AND
                end
                default: ALUCtl = 4'b1111; // Default (NOP)
            endcase
        end

        default: ALUCtl = 4'b1111; // Default (NOP)
    endcase
end

endmodule
