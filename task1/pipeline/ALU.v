module ALU (
    input [3:0] ALUCtl,
    input [31:0] A, B,
    output reg [31:0] ALUOut,
    output zero
);

wire slt, slti;
assign slt = (A < B) ? 1 : 0;   // SLT (Set Less Than)
assign slti = ($signed(A) < $signed(B)) ? 1 : 0;  // SLTI (Immediate Version)

function automatic [4:0] count_trailing_zeros(input [31:0] val);
    integer i;
    begin
        count_trailing_zeros = 32; // Default to 32 if val is 0
        for (i = 0; i < 32; i = i + 1) begin
            if (val[i]) begin
                count_trailing_zeros = i;
            end
        end
    end
endfunction


// ALU operation logic
always @(*) begin
    case (ALUCtl)
        4'b0000: ALUOut = A + B;        // ADD
        4'b0001: ALUOut = A - B;        // SUB
        4'b0010: ALUOut = A & B;        // AND
        4'b0011: ALUOut = A | B;        // OR
        4'b0100: ALUOut = A ^ B;        // XOR
        4'b0101: ALUOut = A << B[4:0];  // SLL
        4'b0110: ALUOut = A >> B[4:0];  // SRL
        4'b0111: ALUOut = $signed(A) >>> B[4:0]; // SRA
        4'b1000: ALUOut = slt;          // SLT
        4'b1001: ALUOut = slti;         // SLTI
        4'b1010: ALUOut = A - B;        // SUB (Branch Comparison)
        4'b1111: ALUOut = count_trailing_zeros(A); // CTZ operation
        default: ALUOut = 32'b0;        // Default case
    endcase
end

assign zero = (ALUOut == 0) ? 1 : 0;

endmodule
