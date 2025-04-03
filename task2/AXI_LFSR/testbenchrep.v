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
    reg [31:0] captured_data [0:31]; // Increased array size to capture more outputs
    integer capture_idx = 0;
    
    // For storing read data from AXI-Lite transactions
    reg [C_AXIL_DATA_WIDTH-1:0] read_data;
    reg [31:0] temp;
    
    // For tracking value occurrences
    integer value_count [0:255];
    integer bin_count [0:7];
    reg seen_values [0:255];
    integer i;
    
    // Timeout counter variable
    integer timeout_counter;
    // Extract fields from captured data
            reg [3:0] packet_header;
            reg [7:0] packet_count;
            reg [11:0] packet_addr;
            reg [7:0] packet_value;
            reg [2:0] packet_bin_idx;
            reg [63:0] status;
            reg is_duplicate;
            reg [3:0] output_header;
            
    //-------------------------------------------------------------------------
    // Function to decode bin number from storage address field.
    // Maps the actual address to bin number based on address ranges
    //-------------------------------------------------------------------------
    function [2:0] decode_bin;
        input [11:0] addr;
        begin
            if (addr >= 12'h020 && addr < 12'h040) decode_bin = 3'd0;
            else if (addr >= 12'h040 && addr < 12'h060) decode_bin = 3'd1;
            else if (addr >= 12'h060 && addr < 12'h080) decode_bin = 3'd2;
            else if (addr >= 12'h080 && addr < 12'h0A0) decode_bin = 3'd3;
            else if (addr >= 12'h0A0 && addr < 12'h0C0) decode_bin = 3'd4;
            else if (addr >= 12'h0C0 && addr < 12'h0E0) decode_bin = 3'd5;
            else if (addr >= 12'h0E0 && addr < 12'h100) decode_bin = 3'd6;
            else if (addr >= 12'h100 && addr < 12'h120) decode_bin = 3'd7;
            else decode_bin = 3'd0; // Default if unknown
        end
    endfunction
    
    //-------------------------------------------------------------------------
    // Function to convert bin index to a descriptive range
    //-------------------------------------------------------------------------
    function [63:0] bin_range;
        input [2:0] bin;
        begin
            case (bin)
                3'd0: bin_range = "0-32";
                3'd1: bin_range = "33-64";
                3'd2: bin_range = "65-96";
                3'd3: bin_range = "97-128";
                3'd4: bin_range = "129-160";
                3'd5: bin_range = "161-192";
                3'd6: bin_range = "193-224";
                3'd7: bin_range = "225-255";
                default: bin_range = "Unknown";
            endcase
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
        $dumpfile("top_module_tb1.vcd");
        $dumpvars(0, top_module_tb);
        output_header = 4'b0000;
        
        // Initialize all AXI signals
        s_axi_awvalid = 0;
        s_axi_wvalid = 0;
        s_axi_bready = 0;
        s_axi_arvalid = 0;
        s_axi_rready = 0;
        m_axis_tready = 0;

        // Initialize tracking arrays
        for (i = 0; i < 256; i = i + 1) begin
            value_count[i] = 0;
            seen_values[i] = 0;
        end
        
        for (i = 0; i < 8; i = i + 1) begin
            bin_count[i] = 0;
        end
        
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
        output_header = m_axis_tdata[31:28];
        
        // Read default configuration registers
        axil_read(4'h0, temp); // start_reg
        axil_read(4'h4, temp); // stop_reg
        axil_read(4'h8, temp); // seed_reg
        axil_read(4'hC, temp); // taps_reg
        
        // Configure LFSR with seed and taps that will generate repeating values
        // This seed and tap combination will create a short sequence with frequent repeats
        axil_write(4'h8, 32'h00000007);  // Seed = 5 (small seed value)
        axil_write(4'hC, 32'h0000000D);  // Taps = 3 (bits 0 and 1 tapped for XOR)
        
        // Verify configuration by reading back
        axil_read(4'h8, temp);
        axil_read(4'hC, temp);
        
        // Start LFSR
        $display("Starting LFSR with configuration designed to produce repeated values...");
        axil_write(4'h0, 32'h00000001);  // start_reg = 1
        
        // Enable AXI-Stream master to accept output from RAM
        $display("Setting m_axis_tready = 1");
        m_axis_tready = 1;
        
        // Capture and decode more output packets
        $display("\n=============================================");
        $display("Capturing Output Packets");
        $display("=============================================");
        $display("Pkt# | Header | Value | Bin# | Bin Range | Count | Address | Status");
        $display("-----+--------+-------+------+-----------+-------+---------+--------");
        
        // Capture 24 packets to ensure we see some duplicates
        for (capture_idx = 0; capture_idx < 32; capture_idx = capture_idx + 1) begin
            timeout_counter = 0;
            while (!m_axis_tvalid && (timeout_counter < TIMEOUT)) begin
                @(posedge aclk);
                timeout_counter = timeout_counter + 1;
            end
            if (timeout_counter >= TIMEOUT) begin
                $display("NOTE: No more output packets after %0d packets", capture_idx);
                capture_idx = 32; // Set to max to exit loop
            end
            
            captured_data[capture_idx] = m_axis_tdata;
            
            
            
            packet_header = captured_data[capture_idx][31:28];
            packet_count = captured_data[capture_idx][27:20];
            packet_addr = captured_data[capture_idx][19:8];
            packet_value = captured_data[capture_idx][7:0];
            packet_bin_idx = decode_bin(packet_addr);
            
            // Track occurrences
            value_count[packet_value] = value_count[packet_value] + 1;
            
            // Determine if this is a duplicate (from our testbench tracking)
            
            is_duplicate = 0;
            if (value_count[packet_value] > 1) is_duplicate = 1;
            
            // Determine status message based on header
            
            status = "Unknown";
            if (packet_header == 4'b0000) begin
                status = "New";
                bin_count[packet_bin_idx] = bin_count[packet_bin_idx] + 1;
                seen_values[packet_value] = 1;
            end else if (packet_header == 4'b0001) begin
                status = "Duplicate";
                if (!seen_values[packet_value]) begin
                    $display("WARNING: Value %0d marked as duplicate but never seen before!", packet_value);
                end
            end else begin
                status = "Unknown";
            end
            
            // Display formatted output
            $display("%3d  |  0x%1h   |  %3d  |  %1d   | %8s | %3d   |  0x%3h  | %s", 
                     capture_idx, packet_header, packet_value, packet_bin_idx, bin_range(packet_bin_idx), 
                     packet_count, packet_addr, status);
            
            @(posedge aclk);
        end
        
        // Stop LFSR
        $display("\nStopping LFSR...");
        axil_write(4'h4, 32'h00000001);  // stop_reg = 1
        
        // Display summary information
        $display("\n=============================================");
        $display("Summary Information");
        $display("=============================================");
        
        $display("\nValue occurrences in captured packets:");
        $display("Value | Count | Status");
        $display("------+-------+--------");
        for (i = 0; i < 256; i = i + 1) begin
            if (value_count[i] > 0) begin
                $display("%4d  | %4d  | %s", i, value_count[i], 
                         (value_count[i] > 1) ? "Duplicate Detected" : "Unique");
            end
        end
        
        $display("\nBin statistics:");
        $display("Bin# | Range     | Count");
        $display("-----+-----------+-------");
        for (i = 0; i < 8; i = i + 1) begin
            $display("%3d  | %8s | %4d", i, bin_range(i), bin_count[i]);
        end
        
        $display("\nTest complete.");
        repeat(10) @(posedge aclk);
        $finish;
    end

endmodule