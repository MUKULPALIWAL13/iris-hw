module axi_stream_fifo #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH = 16
)(
    input  aclk,
    input  aresetn,
    // AXI-Stream Slave Input
    input  [DATA_WIDTH-1:0] s_axis_tdata,
    input  s_axis_tvalid,
    output reg              s_axis_tready,
    // AXI-Stream Master Output
    output reg [DATA_WIDTH-1:0] m_axis_tdata,
    output reg              m_axis_tvalid,
    input                   m_axis_tready
);

    // Compute the number of bits needed for the pointers
    localparam PTR_WIDTH = $clog2(DEPTH);

    // Internal signals
    reg [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];
    reg [PTR_WIDTH:0] write_ptr;
    reg [PTR_WIDTH:0] read_ptr;
    reg [PTR_WIDTH:0] count;
    
    wire write_enable;
    wire read_enable;
    wire fifo_empty;
    wire fifo_full;
    
    // Control signals
    assign write_enable = s_axis_tvalid && s_axis_tready;
    assign read_enable = m_axis_tvalid && m_axis_tready;
    assign fifo_empty = (count == 0);
    assign fifo_full = (count == DEPTH);

    // FIFO write logic
    always @(posedge aclk) begin
        if (!aresetn) begin
            write_ptr <= 0;
        end else if (write_enable) begin
            fifo_mem[write_ptr[PTR_WIDTH-1:0]] <= s_axis_tdata;
            write_ptr <= write_ptr + 1;
        end
    end

    // FIFO read logic
    always @(posedge aclk) begin
        if (!aresetn) begin
            read_ptr <= 0;
        end else if (read_enable) begin
            read_ptr <= read_ptr + 1;
        end
    end

    // FIFO count logic - properly handles simultaneous read/write
    always @(posedge aclk) begin
        if (!aresetn) begin
            count <= 0;
        end else begin
            case ({write_enable, read_enable})
                2'b10: count <= count + 1; // Write only
                2'b01: count <= count - 1; // Read only
                2'b11: count <= count;     // Read and write simultaneously
                default: count <= count;   // No operation
            endcase
        end
    end

    // Output data and valid signal management
    always @(posedge aclk) begin
        if (!aresetn) begin
            m_axis_tvalid <= 0;
            m_axis_tdata <= {DATA_WIDTH{1'b0}};
        end else begin
            // Update valid signal
            if (fifo_empty) begin
                if (write_enable) begin
                    // Special case: if FIFO was empty but we just wrote data
                    m_axis_tvalid <= 1;
                    m_axis_tdata <= s_axis_tdata; // Forward data directly
                end else begin
                    m_axis_tvalid <= 0;
                end
            end else begin
                // FIFO has data
                m_axis_tvalid <= 1;
                
                // Update output data when read occurs or when transitioning from empty
                if (read_enable || !m_axis_tvalid) begin
                    m_axis_tdata <= fifo_mem[read_ptr[PTR_WIDTH-1:0]];
                end
            end
        end
    end

    // Input ready signal - ready when not full
    always @(posedge aclk) begin
        if (!aresetn) begin
            s_axis_tready <= 1; // Ready after reset
        end else begin
            s_axis_tready <= !fifo_full;
        end
    end

endmodule