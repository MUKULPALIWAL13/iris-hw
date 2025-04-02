`include "ramnew.v"
`include "lfsrnew.v"
`include "histnew.v"
`include "fifonew.v" // Include the FIFO module
`include "fifototxt.v"

module top_module_full (
    input aclk,
    input aresetn,
    // AXI-Lite interface for LFSR configuration (from processor)
    input  [3:0] s_axi_awaddr,
    input        s_axi_awvalid,
    output       s_axi_awready,
    input  [31:0] s_axi_wdata,
    input        s_axi_wvalid,
    output       s_axi_wready,
    output [1:0] s_axi_bresp,
    output       s_axi_bvalid,
    input        s_axi_bready,
    input  [3:0] s_axi_araddr,
    input        s_axi_arvalid,
    output       s_axi_arready,
    output [31:0] s_axi_rdata,
    output [1:0] s_axi_rresp,
    output       s_axi_rvalid,
    input        s_axi_rready,
    // Top-level AXI-Stream output from the RAM module
    output [31:0] m_axis_tdata,
    output        m_axis_tvalid,
    input         m_axis_tready
);

    // Internal wires
    wire [31:0] lfsr_stream_data;
    wire        lfsr_stream_valid;
    wire        lfsr_stream_ready;
    
    wire [31:0] fifo_stream_data;
    wire        fifo_stream_valid;
    wire        fifo_stream_ready;
    
    wire [31:0] hist_stream_data;
    wire        hist_stream_valid;
    wire        hist_stream_ready;
    
    // LFSR Module
    s_axil #(
        .C_AXIL_ADDR_WIDTH(4),
        .C_AXIL_DATA_WIDTH(32)
    ) u_axil (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready),
        .m_axis_tdata(lfsr_stream_data),
        .m_axis_tvalid(lfsr_stream_valid),
        .m_axis_tready(lfsr_stream_ready)
    );
    
    // FIFO Module
    axi_stream_fifo #(
        .DATA_WIDTH(32),
        .DEPTH(16) // FIFO depth
    ) u_fifo (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_tdata(lfsr_stream_data),
        .s_axis_tvalid(lfsr_stream_valid),
        .s_axis_tready(lfsr_stream_ready),
        .m_axis_tdata(fifo_stream_data),
        .m_axis_tvalid(fifo_stream_valid),
        .m_axis_tready(fifo_stream_ready)
    );
    
    // Histogram Module
    s_m_hist u_hist (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_tdata(fifo_stream_data),
        .s_axis_tvalid(fifo_stream_valid),
        .s_axis_tready(fifo_stream_ready),
        .m_axis_tdata(hist_stream_data),
        .m_axis_tvalid(hist_stream_valid),
        .m_axis_tready(hist_stream_ready)
    );
    
    // RAM Module
    axi_ram u_ram (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_tdata(hist_stream_data),
        .s_axis_tvalid(hist_stream_valid),
        .s_axis_tready(hist_stream_ready),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready)
    );
    
    // FIFO Logger Module
    fifo_logger u_fifo_logger (
        .aclk(aclk),
        .aresetn(aresetn),
        .fifo_data(fifo_stream_data),
        .fifo_valid(fifo_stream_valid)
    );
    
endmodule
