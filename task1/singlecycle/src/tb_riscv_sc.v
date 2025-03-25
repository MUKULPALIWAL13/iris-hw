module tb_riscv_sc;
// CPU testbench

reg clk;
reg start;

// Instantiate Single Cycle CPU
SingleCycleCPU riscv_DUT(clk, start);

// Clock Generation
initial
    forever #5 clk = ~clk; // 10ns clock cycle

// Test Procedure
initial begin
    // Initialize waveform dumping
    $dumpfile("riscv_waveform.vcd");  // Dump data into this file
    $dumpvars(0, tb_riscv_sc);  // Dump all signals of testbench

    clk = 0;
    start = 0;
    #10 start = 1; // Start the processor after 10 time units

    #3000 $finish;  // Stop simulation after 3000 time units
end

endmodule
