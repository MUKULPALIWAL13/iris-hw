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

    // Compute the number of bits needed for the pointers.
    localparam PTR_WIDTH = $clog2(DEPTH);

    reg [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];
    reg [PTR_WIDTH:0] write_ptr;
    reg [PTR_WIDTH:0] read_ptr;
    reg [PTR_WIDTH:0] count;

    // Write logic
    always @(posedge aclk) begin
        if (!aresetn) begin
            write_ptr <= 0;
            count <= 0;
        end else if (s_axis_tvalid && s_axis_tready) begin
            fifo_mem[write_ptr[PTR_WIDTH-1:0]] <= s_axis_tdata;
            write_ptr <= write_ptr + 1;
            count <= count + 1;
        end
    end

    // Read logic
    always @(posedge aclk) begin
        if (!aresetn) begin
            read_ptr <= 0;
        end else if (m_axis_tvalid && m_axis_tready) begin
            read_ptr <= read_ptr + 1;
            count <= count - 1;
        end
    end

    // Output logic: Present data when available
    always @(posedge aclk) begin
        if (!aresetn) begin
            m_axis_tvalid <= 0;
            m_axis_tdata <= {DATA_WIDTH{1'b0}};
        end else begin
            if (count > 0) begin
                m_axis_tvalid <= 1;
                m_axis_tdata <= fifo_mem[read_ptr[PTR_WIDTH-1:0]];
            end else begin
                m_axis_tvalid <= 0;
            end
        end
    end

    // s_axis_tready logic: Ready when FIFO is not full
    always @(posedge aclk) begin
        if (!aresetn)
            s_axis_tready <= 1;
        else
            s_axis_tready <= (count < DEPTH);
    end

endmodule
