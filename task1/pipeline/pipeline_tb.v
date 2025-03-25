// `include "pipelinetop.v"
module tb();

    reg clk = 0, rst;
    
    // Generate clock signal with a period of 100 time units (50 high + 50 low)
    always begin
        clk = ~clk;
        #50;
    end

    initial begin
        rst <= 1'b0;
        #200;
        rst <= 1'b1;
        #5000;  // Increased time to allow all instructions to execute
        $finish;    
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end

    pipelined_riscv dut (.clk(clk), .rst(rst));
endmodule
