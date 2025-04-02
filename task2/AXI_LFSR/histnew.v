module s_m_hist (
    input aclk,
    input aresetn,

    // AXI-Stream Slave (Input)
    input [31:0] s_axis_tdata, // Incoming data; last 8 bits are the value
    input s_axis_tvalid,
    output reg s_axis_tready,

    // AXI-Stream Master (Output)
    output reg [31:0] m_axis_tdata, // Output data: {4'b0, count, storage_addr, value}
    output reg m_axis_tvalid,
    input m_axis_tready
);
    
    // 8 histogram bins; each bin has a 32-bit count
    reg [31:0] bin_count [7:0];
    // Memory for storing values in bins (with 12-bit addressing)
    reg [7:0] memory [0:4095];//it is of no use we can remove this when we r using seprate logic in ram module 

    // Internal signals for processing
    reg [7:0] value;
    reg [2:0] bin_index;
    reg [11:0] storage_addr;
    reg [7:0] count;

    integer i;

    // Reset logic: Initialize bin counts and handshake signals.
    always @(posedge aclk) begin
        if (!aresetn) begin
            for (i = 0; i < 8; i = i + 1)
                bin_count[i] <= 0;
            m_axis_tvalid <= 0;
            s_axis_tready <= 1;
        end
    end

    // Function: Determine bin index based on value
    function [2:0] get_bin_index;
        input [7:0] value;
        begin
            if (value <= 8'd32) get_bin_index = 3'd0;
            else if (value <= 8'd64) get_bin_index = 3'd1;
            else if (value <= 8'd96) get_bin_index = 3'd2;
            else if (value <= 8'd128) get_bin_index = 3'd3;
            else if (value <= 8'd160) get_bin_index = 3'd4;
            else if (value <= 8'd192) get_bin_index = 3'd5;
            else if (value <= 8'd224) get_bin_index = 3'd6;
            else get_bin_index = 3'd7;
        end
    endfunction

    // Function: Determine the base storage address for a given bin
    function [11:0] get_storage_address;
        input [2:0] bin;
        begin
            case (bin)
                3'd0: get_storage_address = 12'h020;
                3'd1: get_storage_address = 12'h040;
                3'd2: get_storage_address = 12'h060;
                3'd3: get_storage_address = 12'h080;
                3'd4: get_storage_address = 12'h0A0;
                3'd5: get_storage_address = 12'h0C0;
                3'd6: get_storage_address = 12'h0E0;
                3'd7: get_storage_address = 12'h100;
                default: get_storage_address = 12'h020; // default to bin 0
            endcase
        end
    endfunction

    // Main processing logic with improved handshake handling.
    // We use nonblocking assignments for sequential updates.
    always @(posedge aclk) begin
        if (!aresetn) begin
            // Already handled in reset block above.
            m_axis_tvalid <= 0;
            s_axis_tready <= 1;
        end else begin
            // If new input is valid and we're ready to accept it...
            if (s_axis_tvalid && s_axis_tready) begin
                // Capture the 8-bit value from the incoming data.
                value <= s_axis_tdata[7:0];
                // Determine which bin this value belongs to.
                bin_index <= get_bin_index(s_axis_tdata[7:0]);
                // Determine the base storage address for that bin.
                storage_addr <= get_storage_address(get_bin_index(s_axis_tdata[7:0]));
                
                // Calculate the new count using the current bin count.
                count <= bin_count[get_bin_index(s_axis_tdata[7:0])] + 1;
                // Update the bin count.
                bin_count[get_bin_index(s_axis_tdata[7:0])] <= bin_count[get_bin_index(s_axis_tdata[7:0])] + 1;
                
                // Store the value in memory at the address:
                // base storage address + (new count value)
                memory[storage_addr + count] <= s_axis_tdata[7:0];//it is of no use we can remove this when we r using seprate logic in ram module 
                //we have one logic to get excat memory from offset and base address in ram module so no need of this 
                
                // Prepare the output packet.
                // Packet format: {4'b0000, count[7:0], storage_addr[11:0], value[7:0]}
                // Note: Here, we assume the concatenation yields a 32-bit word.
                m_axis_tdata <= {4'b0000, count, storage_addr, value};
                m_axis_tvalid <= 1;
                // Deassert s_axis_tready to avoid accepting new data until this output is accepted.
                s_axis_tready <= 0;
            end 
            // If the output has been accepted by the downstream module...
            else if (m_axis_tvalid && m_axis_tready) begin
                // Clear the valid signal and reassert readiness for new input.
                m_axis_tvalid <= 0;
                s_axis_tready <= 1;
            end
            // Else, if m_axis_tvalid is still high and m_axis_tready is low, hold the valid signal.
            else begin
                m_axis_tvalid <= m_axis_tvalid;
                s_axis_tready <= s_axis_tready;
            end
        end
    end

endmodule
