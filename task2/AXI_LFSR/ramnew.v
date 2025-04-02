module axi_ram (
    input aclk,
    input aresetn,

    // AXI-Stream Slave
    input [31:0] s_axis_tdata,
    input s_axis_tvalid,
    output reg s_axis_tready,

    // AXI-Stream Master
    output reg [31:0] m_axis_tdata,
    output reg m_axis_tvalid,
    input m_axis_tready
);

    // Memory array (each address stores an 8-bit value)
    reg [7:0] mem [0:288];
    reg [7:0] bin_counters [7:0]; // Counter storage for each bin
    
    integer i;
    
    // Extract fields from input data
    wire [3:0] header    = s_axis_tdata[31:28]; // Fixed 4'b0000 (not used)
    wire [7:0] counter   = s_axis_tdata[27:20]; // Bin counter value
    wire [11:0] reg_addr = s_axis_tdata[19:8];  // Base storage address for bin
    wire [7:0] number    = s_axis_tdata[7:0];   // Value to store
    
    reg [11:0] write_addr; // Computed write address
    
    always @(posedge aclk) begin
        if (!aresetn) begin
            s_axis_tready <= 1;
            m_axis_tvalid <= 0;
            
            // Reset memory and counters
            for (i = 0; i < 8; i = i + 1) bin_counters[i] <= 0;
        end else if (s_axis_tvalid && s_axis_tready) begin
            
            // Compute the actual write address using base + counter
            write_addr = reg_addr + counter;
            
            // Store the value in memory
            mem[write_addr] <= number;
            
            // Increment bin counter
            bin_counters[reg_addr[4:2]] <= bin_counters[reg_addr[4:2]] + 1;
            
            // Send data to Master interface
            if (!m_axis_tvalid || m_axis_tready) begin
                m_axis_tdata <= {4'b0000, bin_counters[reg_addr[4:2]], write_addr, number};
                m_axis_tvalid <= 1;
            end
        end else if (m_axis_tvalid && !m_axis_tready) begin
            m_axis_tvalid <= 1; // Hold data until it is accepted
        end else begin
            m_axis_tvalid <= 0;
        end
    end
endmodule