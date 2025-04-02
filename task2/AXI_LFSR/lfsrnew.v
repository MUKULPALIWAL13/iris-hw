//////////////////////////////////////////////////////////////////////////////////
//  8-Bit LFSR with AXI-Lite Slave Interface for Configuration and AXI-Stream 
//  Master Interface for LFSR Output
//
//  Address Map:
//    0x00 - start_reg (bit0 only)
//    0x04 - stop_reg  (bit0 only)
//    0x08 - seed_reg  (8-bit seed)
//    0x0C - taps_reg  (8-bit tap mask)
// 
//  The LFSR loads the seed when start_reg is asserted and then shifts 
//  on every clock (when the AXI-Stream master is ready) until stop_reg is asserted.
//////////////////////////////////////////////////////////////////////////////////

module s_axil #(
    parameter C_AXIL_ADDR_WIDTH = 4,
    parameter C_AXIL_DATA_WIDTH = 32
)(
    input aclk,
    input aresetn,

    // AXI-Lite Slave Interface
    input  [C_AXIL_ADDR_WIDTH-1:0] s_axi_awaddr,
    input                       s_axi_awvalid,
    output reg                  s_axi_awready,

    input  [C_AXIL_DATA_WIDTH-1:0] s_axi_wdata,
    input                       s_axi_wvalid,
    output reg                  s_axi_wready,

    output reg [1:0]            s_axi_bresp,
    output reg                  s_axi_bvalid,
    input                       s_axi_bready,

    input  [C_AXIL_ADDR_WIDTH-1:0] s_axi_araddr,
    input                       s_axi_arvalid,
    output reg                  s_axi_arready,

    output reg [C_AXIL_DATA_WIDTH-1:0] s_axi_rdata,
    output reg [1:0]            s_axi_rresp,
    output reg                  s_axi_rvalid,
    input                       s_axi_rready,

    // AXI-Stream Master Interface
    output reg [C_AXIL_DATA_WIDTH-1:0] m_axis_tdata,
    output reg                    m_axis_tvalid,
    input                         m_axis_tready
);

    // Address map for registers:
    // 0x00 - start_reg
    // 0x04 - stop_reg
    // 0x08 - seed_reg
    // 0x0C - taps_reg

    // Configuration Registers
    reg start_reg;
    reg stop_reg;
    reg [7:0] seed_reg;
    reg [7:0] taps_reg;

    // Internal LFSR state and enable flag
    reg [7:0] lfsr_reg;
    reg       lfsr_running;

    //-------------------------------------------------------------------------
    // AXI-Lite Write Channel
    //-------------------------------------------------------------------------
    always @(posedge aclk) begin
        if (!aresetn) begin
            s_axi_awready <= 1'b0;
            s_axi_wready  <= 1'b0;
            s_axi_bvalid  <= 1'b0;
            s_axi_bresp   <= 2'b00;
            // Reset configuration registers
            start_reg     <= 1'b0;
            stop_reg      <= 1'b0;
            seed_reg      <= 8'h01;
            taps_reg      <= 8'hB4;
        end else begin
            // Handshake for write address
            if (s_axi_awvalid && !s_axi_awready)
                s_axi_awready <= 1'b1;
            else
                s_axi_awready <= 1'b0;

            // Handshake for write data
            if (s_axi_wvalid && !s_axi_wready)
                s_axi_wready <= 1'b1;
            else
                s_axi_wready <= 1'b0;

            // When both address and data are valid, perform the write
            if (s_axi_awvalid && s_axi_awready && s_axi_wvalid && s_axi_wready) begin
                case(s_axi_awaddr)
                    4'h0: start_reg <= s_axi_wdata[0];  // Only bit0 is used
                    4'h4: stop_reg  <= s_axi_wdata[0];
                    4'h8: seed_reg  <= s_axi_wdata[7:0];
                    4'hC: taps_reg  <= s_axi_wdata[7:0];
                    default: ;
                endcase
                s_axi_bvalid <= 1'b1;
                s_axi_bresp  <= 2'b00;  // OKAY response
            end else if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bvalid <= 1'b0;
            end
        end
    end

    //-------------------------------------------------------------------------
    // AXI-Lite Read Channel
    //-------------------------------------------------------------------------
    always @(posedge aclk) begin
        if (!aresetn) begin
            s_axi_arready <= 1'b0;
            s_axi_rvalid  <= 1'b0;
            s_axi_rresp   <= 2'b00;
            s_axi_rdata   <= {C_AXIL_DATA_WIDTH{1'b0}};
        end else begin
            if (s_axi_arvalid && !s_axi_arready)
                s_axi_arready <= 1'b1;
            else
                s_axi_arready <= 1'b0;

            if (s_axi_arvalid && s_axi_arready) begin
                case(s_axi_araddr)
                    4'h0: s_axi_rdata <= {31'd0, start_reg};
                    4'h4: s_axi_rdata <= {31'd0, stop_reg};
                    4'h8: s_axi_rdata <= {24'd0, seed_reg};
                    4'hC: s_axi_rdata <= {24'd0, taps_reg};
                    default: s_axi_rdata <= {C_AXIL_DATA_WIDTH{1'b0}};
                endcase
                s_axi_rvalid <= 1'b1;
                s_axi_rresp  <= 2'b00;  // OKAY response
            end else if (s_axi_rvalid && s_axi_rready) begin
                s_axi_rvalid <= 1'b0;
            end
        end
    end

    //-------------------------------------------------------------------------
    // 8-Bit LFSR Logic
    //-------------------------------------------------------------------------
    // Feedback is the XOR (reduction XOR) of the tapped bits.
    wire feedback = ^(lfsr_reg & taps_reg);

    always @(posedge aclk) begin
        if (!aresetn) begin
            lfsr_reg    <= 8'd1;
            lfsr_running<= 1'b0;
        end else begin
            // Start the LFSR: if start_reg is asserted and LFSR not yet running,
            // load the seed value.
            if (start_reg && !lfsr_running) begin
                lfsr_reg    <= seed_reg;
                lfsr_running<= 1'b1;
                start_reg   <= 1'b0; // Clear start_reg after starting
            end 
            // Stop the LFSR if stop_reg is asserted
            else if (stop_reg) begin
                lfsr_running <= 1'b0;
            end 
            // Otherwise, if LFSR is running, update its state on every cycle
            // when the AXI-Stream master is ready to accept data.
            else if (lfsr_running && m_axis_tready) begin
                lfsr_reg <= {lfsr_reg[6:0], feedback};
            end
        end
    end

    //-------------------------------------------------------------------------
    // AXI-Stream Master Interface for LFSR Output
    //-------------------------------------------------------------------------
    always @(posedge aclk) begin
        if (!aresetn) begin
            m_axis_tdata  <= {C_AXIL_DATA_WIDTH{1'b0}};
            m_axis_tvalid <= 1'b0;
        end else begin
            // When LFSR is running, drive the LFSR state out as data.
            if (lfsr_running && m_axis_tready) begin
                // Extend the 8-bit LFSR value to the AXI-Stream data width.
                m_axis_tdata  <= {{(C_AXIL_DATA_WIDTH-8){1'b0}}, lfsr_reg};
                m_axis_tvalid <= 1'b1;
            end else if (!m_axis_tready) begin
                m_axis_tvalid <= 1'b0;
            end
            else begin 
                 m_axis_tvalid <= 1'b0;
            end
        end
    end

endmodule
