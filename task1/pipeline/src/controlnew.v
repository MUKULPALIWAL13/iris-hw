module controlnew(
    input [6:0] opcode,
    input [6:0] funct7,   // funct7 is 7-bit
    input [2:0] funct3,
    output reg branch, memRead, memtoReg, memWrite, ALUSrc, regWrite,
    output reg [3:0] ALUCtl
);

    // ALUOp is used internally (not an output)
    reg [1:0] ALUOp;
    reg ctz ;
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
                ALUCtl = 4'b1111;  // Directly set ALUCtl
            end
        endcase
    end

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
                    3'b000: ALUCtl = (funct7[5]) ? 4'b0001 : 4'b0000; // SUB (funct7[5]=1) or ADD (funct7[5]=0)
                    3'b001: ALUCtl = 4'b0101; // SLL (Shift Left Logical)
                    3'b010: ALUCtl = 4'b1000; // SLT (Set Less Than)
                    3'b011: ALUCtl = 4'b1001; // SLTU (Set Less Than Unsigned)
                    3'b100: ALUCtl = 4'b0100; // XOR
                    3'b101: ALUCtl = (funct7[5]) ? 4'b0111 : 4'b0110; // SRA (funct7[5]=1) or SRL (funct7[5]=0)
                    3'b110: ALUCtl = 4'b0011; // OR
                    3'b111: ALUCtl = 4'b0010; // AND
                    default: ALUCtl = 4'b1111; // Default (NOP)
                endcase
            end

            default: ALUCtl = 4'b1111; // Default (NOP)
        endcase
    end

endmodule
