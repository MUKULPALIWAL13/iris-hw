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
    
    // Explicit bin counters with specific addresses
    reg [7:0] bin0_counter; // For addresses 0x020-0x03F
    reg [7:0] bin1_counter; // For addresses 0x040-0x05F
    reg [7:0] bin2_counter; // For addresses 0x060-0x07F
    reg [7:0] bin3_counter; // For addresses 0x080-0x09F
    reg [7:0] bin4_counter; // For addresses 0x0A0-0x0BF
    reg [7:0] bin5_counter; // For addresses 0x0C0-0x0DF
    reg [7:0] bin6_counter; // For addresses 0x0E0-0x0FF
    reg [7:0] bin7_counter; // For addresses 0x100-0x11F
    
    // Tracking register for unique numbers
    reg number_seen [0:255];
    
    // Storage locations for each number (where was this number stored?)
    reg [11:0] number_address [0:255];
    
    // Local storage for current packet data
    reg [7:0] current_value;     // Current value being processed
    reg [11:0] current_bin_addr; // Current bin address
    
    // Debugging signals
    reg is_duplicate;            // Flag indicating if current value is a duplicate
    reg [3:0] output_header;     // Header for output packet
    reg [7:0] count_in;          // Input count from histogram
    
    integer i;
    
    // Extract fields from input data
    wire [3:0] header    = s_axis_tdata[31:28]; // Fixed 4'b0000 (from s_m_hist)
    wire [7:0] count     = s_axis_tdata[27:20]; // Bin counter value from histogram
    wire [11:0] bin_addr = s_axis_tdata[19:8];  // Base storage address for bin
    wire [7:0] value     = s_axis_tdata[7:0];   // Value to store
    
    // Wire to get bin index from address
    wire [2:0] bin_index = get_bin_index(bin_addr);
    
    // Current bin counter value - directly mapped to avoid delay
    reg [7:0] count_out;
    
    reg [11:0] write_addr; // Computed write address
    
    // Function to get bin index from base address
    function [2:0] get_bin_index;
        input [11:0] addr;
        begin
            case (addr)
                12'h020: get_bin_index = 3'd0;
                12'h040: get_bin_index = 3'd1;
                12'h060: get_bin_index = 3'd2;
                12'h080: get_bin_index = 3'd3;
                12'h0A0: get_bin_index = 3'd4;
                12'h0C0: get_bin_index = 3'd5;
                12'h0E0: get_bin_index = 3'd6;
                12'h100: get_bin_index = 3'd7;
            endcase
        end
    endfunction
    
    // Function to get the current bin counter value directly
    function [7:0] get_bin_counter;
        input [2:0] idx;
        begin
            case (idx)
                3'd0: get_bin_counter = bin0_counter;
                3'd1: get_bin_counter = bin1_counter;
                3'd2: get_bin_counter = bin2_counter;
                3'd3: get_bin_counter = bin3_counter; 
                3'd4: get_bin_counter = bin4_counter;
                3'd5: get_bin_counter = bin5_counter;
                3'd6: get_bin_counter = bin6_counter;
                3'd7: get_bin_counter = bin7_counter;
            endcase
        end
    endfunction
    
    always @(posedge aclk) begin
        if (!aresetn) begin
            s_axis_tready <= 1;
            m_axis_tvalid <= 0;
            
            // Reset bin counters
            bin0_counter <= 0;
            bin1_counter <= 0;
            bin2_counter <= 0;
            bin3_counter <= 0;
            bin4_counter <= 0;
            bin5_counter <= 0;
            bin6_counter <= 0;
            bin7_counter <= 0;
            
            // Initialize tracking registers
            for (i = 0; i < 256; i = i + 1) begin
                number_seen[i] <= 0;
                number_address[i] <= 0;
            end
            
            // Reset debugging signals
            is_duplicate <= 0;
            output_header <= 4'b0000;
            count_in <= 0;
            count_out <= 0;
            
            // Reset local storage
            current_value <= 0;
            current_bin_addr <= 0;
        end else if (s_axis_tvalid && s_axis_tready) begin
            // Store incoming values locally
            current_value <= value;
            current_bin_addr <= bin_addr;
            count_in <= count;
            
            // Use local value for duplicate check
            is_duplicate <= number_seen[value];
            
            if (!number_seen[value]) begin
                // First occurrence of this number
                output_header <= 4'b0000;
                
                // Mark this number as seen - use value directly to avoid timing issues
                number_seen[value] <= 1'b1;
                
                // Calculate write address and update bin counter based on bin index
                case (bin_index)
                    3'd0: begin
                        // Use blocking assignment to update count_out immediately
                        bin0_counter = bin0_counter + 1;
                        count_out = bin0_counter; 
                        write_addr = bin_addr + bin0_counter;
                       
                    end
                    3'd1: begin
                        bin1_counter = bin1_counter + 1;
                        count_out = bin1_counter;
                        write_addr = bin_addr + bin1_counter;
                        
                    end
                    3'd2: begin
                        bin2_counter = bin2_counter + 1;
                        count_out = bin2_counter;
                        write_addr = bin_addr + bin2_counter;
                        
                    end
                    3'd3: begin
                        bin3_counter = bin3_counter + 1;
                        count_out = bin3_counter;
                        write_addr = bin_addr + bin3_counter;
                       
                    end
                    3'd4: begin
                        bin4_counter = bin4_counter + 1;
                        count_out = bin4_counter;
                        write_addr = bin_addr + bin4_counter;
                        
                    end
                    3'd5: begin
                        bin5_counter = bin5_counter + 1;
                        count_out = bin5_counter;
                        write_addr = bin_addr + bin5_counter;
                        
                    end
                    3'd6: begin
                        bin6_counter = bin6_counter + 1;
                        count_out = bin6_counter;
                        write_addr = bin_addr + bin6_counter;
                        
                    end
                    3'd7: begin
                        bin7_counter = bin7_counter + 1;
                        count_out = bin7_counter;
                        write_addr = bin_addr + bin7_counter;
                        
                    end
                endcase
                
                // Store the value in memory
                mem[write_addr] <= value;
                
                // Store where this number was saved
                number_address[value] <= write_addr;
                
                // Send data to Master interface with our counter
                if (!m_axis_tvalid || m_axis_tready) begin
                    m_axis_tdata <= {4'b0000, count_out, write_addr, value};
                    m_axis_tvalid <= 1;
                end
            end else begin
                // This number has been seen before - skip it completely
                output_header <= 4'b0001;
                
                // Get the current counter value for this bin without incrementing
                // Use blocking assignment for immediate update
                case (bin_index)
                    3'd0: count_out = bin0_counter;
                    3'd1: count_out = bin1_counter;
                    3'd2: count_out = bin2_counter;
                    3'd3: count_out = bin3_counter;
                    3'd4: count_out = bin4_counter;
                    3'd5: count_out = bin5_counter;
                    3'd6: count_out = bin6_counter;
                    3'd7: count_out = bin7_counter;
                endcase
                
                // Send a status message with the previous storage address
                if (!m_axis_tvalid || m_axis_tready) begin
                    // Pass along the current bin counter (no increment for duplicates)
                    m_axis_tdata <= {4'b0001, count_out, number_address[value], value};
                    m_axis_tvalid <= 1;
                end
            end
        end else if (m_axis_tvalid && m_axis_tready) begin
            m_axis_tvalid <= 0;
            s_axis_tready <= 1;
        end else if (m_axis_tvalid && !m_axis_tready) begin
            // Hold valid signal until downstream module is ready
            m_axis_tvalid <= 1;
            s_axis_tready <= 0;
        end else begin
            // Ready for new data
            m_axis_tvalid <= 0;
            s_axis_tready <= 1;
        end
    end

endmodule