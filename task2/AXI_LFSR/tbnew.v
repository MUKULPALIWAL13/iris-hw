`timescale 1ns / 1ps

module top_module_tb;

    // Parameters
    parameter C_AXIL_ADDR_WIDTH = 4;
    parameter C_AXIL_DATA_WIDTH = 32;
    parameter CLK_PERIOD = 10; // 10 ns period (100MHz)
    parameter TIMEOUT = 10000; // Timeout in clock cycles
    
    // Clock and reset signals
    reg aclk = 0;
    reg aresetn = 0;
    
    // AXI-Lite interface signals (for configuring LFSR)
    reg [C_AXIL_ADDR_WIDTH-1:0] s_axi_awaddr;
    reg s_axi_awvalid;
    wire s_axi_awready;
    
    reg [C_AXIL_DATA_WIDTH-1:0] s_axi_wdata;
    reg s_axi_wvalid;
    wire s_axi_wready;
    
    wire [1:0] s_axi_bresp;
    wire s_axi_bvalid;
    reg s_axi_bready;
    
    reg [C_AXIL_ADDR_WIDTH-1:0] s_axi_araddr;
    reg s_axi_arvalid;
    wire s_axi_arready;
    
    wire [C_AXIL_DATA_WIDTH-1:0] s_axi_rdata;
    wire [1:0] s_axi_rresp;
    wire s_axi_rvalid;
    reg s_axi_rready;
    
    // Top-level AXI-Stream interface from the RAM module (final output)
    wire [31:0] m_axis_tdata;
    wire m_axis_tvalid;
    reg m_axis_tready;
    
    // For capturing output packets (final RAM/histogram output)
    reg [31:0] captured_data [0:15];
    integer capture_idx = 0;
    
    // For storing read data from AXI-Lite transactions
    reg [C_AXIL_DATA_WIDTH-1:0] read_data;
    reg [31:0] temp;
    
    // Timeout counter variable
    integer timeout_counter;
    
    //-------------------------------------------------------------------------
    // Function to decode bin number from storage address field.
    // This function maps the base address to the bin number.
    //-------------------------------------------------------------------------
    function [2:0] decode_bin;
        input [11:0] addr;
        begin
            if (addr == 12'h020) decode_bin = 3'd0;
            else if (addr == 12'h040) decode_bin = 3'd1;
            else if (addr == 12'h060) decode_bin = 3'd2;
            else if (addr == 12'h080) decode_bin = 3'd3;
            else if (addr == 12'h0A0) decode_bin = 3'd4;
            else if (addr == 12'h0C0) decode_bin = 3'd5;
            else if (addr == 12'h0E0) decode_bin = 3'd6;
            else if (addr == 12'h100) decode_bin = 3'd7;
            else decode_bin = 3'd0; // Default if unknown
        end
    endfunction

    //-------------------------------------------------------------------------
    // Instantiate the top-level module
    //-------------------------------------------------------------------------
    top_module_full u_top (
        .aclk         (aclk),
        .aresetn      (aresetn),
        // AXI-Lite interface signals
        .s_axi_awaddr (s_axi_awaddr),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),
        .s_axi_wdata  (s_axi_wdata),
        .s_axi_wvalid (s_axi_wvalid),
        .s_axi_wready (s_axi_wready),
        .s_axi_bresp  (s_axi_bresp),
        .s_axi_bvalid (s_axi_bvalid),
        .s_axi_bready (s_axi_bready),
        .s_axi_araddr (s_axi_araddr),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),
        .s_axi_rdata  (s_axi_rdata),
        .s_axi_rresp  (s_axi_rresp),
        .s_axi_rvalid (s_axi_rvalid),
        .s_axi_rready (s_axi_rready),
        // AXI-Stream interface from RAM output
        .m_axis_tdata (m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready)
    );
    
    // Clock generation
    always #(CLK_PERIOD/2) aclk = ~aclk;
    
    //--------------------------------------------------------------------------
    // AXI-Lite Write Transaction Task
    //--------------------------------------------------------------------------
    task axil_write;
        input [C_AXIL_ADDR_WIDTH-1:0] addr;
        input [C_AXIL_DATA_WIDTH-1:0] data;
        begin
            $display("AXI-Lite Write: addr=0x%h, data=0x%h", addr, data);
            s_axi_awaddr = addr;
            s_axi_awvalid = 1;
            s_axi_wdata = data;
            s_axi_wvalid = 1;
            s_axi_bready = 1;
            
            timeout_counter = 0;
            while (!(s_axi_awready && s_axi_wready) && (timeout_counter < TIMEOUT)) begin
                @(posedge aclk);
                timeout_counter = timeout_counter + 1;
            end
            if (timeout_counter >= TIMEOUT) begin
                $display("ERROR: Timeout waiting for write handshake at addr=0x%h", addr);
                $finish;
            end
            @(posedge aclk);
            s_axi_awvalid = 0;
            s_axi_wvalid = 0;
            
            timeout_counter = 0;
            while (!s_axi_bvalid && (timeout_counter < TIMEOUT)) begin
                @(posedge aclk);
                timeout_counter = timeout_counter + 1;
            end
            if (timeout_counter >= TIMEOUT) begin
                $display("ERROR: Timeout waiting for write response at addr=0x%h", addr);
                $finish;
            end
            @(posedge aclk);
            s_axi_bready = 0;
            $display("Write complete: addr=0x%h, resp=0x%h", addr, s_axi_bresp);
        end
    endtask
    
    //--------------------------------------------------------------------------
    // AXI-Lite Read Transaction Task
    //--------------------------------------------------------------------------
    task axil_read;
        input [C_AXIL_ADDR_WIDTH-1:0] addr;
        output [C_AXIL_DATA_WIDTH-1:0] data;
        begin
            $display("AXI-Lite Read: addr=0x%h", addr);
            s_axi_araddr = addr;
            s_axi_arvalid = 1;
            s_axi_rready = 1;
            
            timeout_counter = 0;
            while (!s_axi_arready && (timeout_counter < TIMEOUT)) begin
                @(posedge aclk);
                timeout_counter = timeout_counter + 1;
            end
            if (timeout_counter >= TIMEOUT) begin
                $display("ERROR: Timeout waiting for read address handshake at addr=0x%h", addr);
                $finish;
            end
            @(posedge aclk);
            s_axi_arvalid = 0;
            
            timeout_counter = 0;
            while (!s_axi_rvalid && (timeout_counter < TIMEOUT)) begin
                @(posedge aclk);
                timeout_counter = timeout_counter + 1;
            end
            if (timeout_counter >= TIMEOUT) begin
                $display("ERROR: Timeout waiting for read data at addr=0x%h", addr);
                $finish;
            end
            data = s_axi_rdata;
            @(posedge aclk);
            s_axi_rready = 0;
            $display("Read complete: addr=0x%h, data=0x%h, resp=0x%h", addr, data, s_axi_rresp);
        end
    endtask
    
    //--------------------------------------------------------------------------
    // Test Sequence: Acts as the processor and monitors outputs from Histogram/RAM
    //--------------------------------------------------------------------------
    initial begin
        // Dump waveform to VCD file
        $dumpfile("top_module_tb.vcd");
        $dumpvars(0, top_module_tb);
        
        // Initialize all AXI signals
        s_axi_awvalid = 0;
        s_axi_wvalid = 0;
        s_axi_bready = 0;
        s_axi_arvalid = 0;
        s_axi_rready = 0;
        m_axis_tready = 0;
        
        $display("\n=============================================");
        $display("Starting Top Module Testbench");
        $display("=============================================");
        
        // Apply reset
        $display("Applying reset...");
        aresetn = 0;
        repeat(5) @(posedge aclk);
        aresetn = 1;
        $display("Reset complete.");
        repeat(2) @(posedge aclk);
        
        // Read default configuration registers
       
        axil_read(4'h0, temp); // start_reg
        axil_read(4'h4, temp); // stop_reg
        axil_read(4'h8, temp); // seed_reg
        axil_read(4'hC, temp); // taps_reg
        
        // Configure LFSR: Write seed and taps
        axil_write(4'h8, 32'h00000042);  // Seed = 0x42
        axil_write(4'hC, 32'h000000B4);   // Taps = 0xB4
        
        // Optionally, verify configuration by reading back
        axil_read(4'h8, temp);
        axil_read(4'hC, temp);
        
        // Start LFSR
        $display("Starting LFSR...");
        axil_write(4'h0, 32'h00000001);  // start_reg = 1
        
        // Check auto-clear of start_reg (if applicable)
        repeat(2) @(posedge aclk);
        axil_read(4'h0, temp);
        
        // Enable AXI-Stream master to accept output from RAM
        $display("Setting m_axis_tready = 1");
        m_axis_tready = 1;
        
        // Capture and decode output packets (from RAM/histogram system)
        for (capture_idx = 0; capture_idx < 16; capture_idx = capture_idx + 1) begin
            $display("Waiting for output packet %0d...", capture_idx);
            timeout_counter = 0;
            while (!m_axis_tvalid && (timeout_counter < TIMEOUT)) begin
                @(posedge aclk);
                timeout_counter = timeout_counter + 1;
            end
            if (timeout_counter >= TIMEOUT) begin
                $display("ERROR: Timeout waiting for output packet %0d", capture_idx);
                $finish;
            end
            
            captured_data[capture_idx] = m_axis_tdata;
            // Decode the packet:
            // Packet format: {4'b0000, count (8 bits), storage_addr (12 bits), value (8 bits)}
            $display("Output packet %0d: 0x%h", capture_idx, captured_data[capture_idx]);
            $display("   Decoded -> Header: 0x%h, Count: 0x%h, Storage Addr: 0x%h, Value: 0x%h", 
                     captured_data[capture_idx][31:28],
                     captured_data[capture_idx][27:20],
                     captured_data[capture_idx][19:8],
                     captured_data[capture_idx][7:0]);
            // Display the bin number based on the storage address.
            $display("   Bin Number: %0d", decode_bin(captured_data[capture_idx][19:8]));
            @(posedge aclk);
        end
        
        // Stop LFSR
        $display("Stopping LFSR...");
        axil_write(4'h4, 32'h00000001);  // stop_reg = 1
        
        // Verify that no new packets appear
        repeat(5) @(posedge aclk);
        if (m_axis_tvalid)
            $display("ERROR: Output still valid after stopping LFSR");
        else
            $display("PASS: LFSR has stopped, no output packets.");
        
        $display("Test complete.");
        repeat(10) @(posedge aclk);
        $finish;
    end

endmodule
