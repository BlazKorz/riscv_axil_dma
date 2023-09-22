import common_cells_pkg::*;

module axil_if #(
  parameter ADDR_WIDTH = 16,
  parameter DATA_WIDTH = 64,
  parameter STRB_WIDTH = (DATA_WIDTH / 8)
  )(
  input aclk,
  input anreset,
  input aenable,
  
  input i_wr_valid,
  input [STRB_WIDTH - 1:0] i_wr_strb,
  input [DATA_WIDTH - 1:0] i_wr_data,
  input [ADDR_WIDTH - 1:0] i_wr_addr,
  output o_wr_ready,
  
  input i_rd_ready,
  input [ADDR_WIDTH - 1:0] i_rd_addr,
  output o_rd_valid,
  output [DATA_WIDTH - 1:0] o_rd_data,
  
  output [ADDR_WIDTH - 1:0] o_awaddr,
  output [2:0] o_awprot,
  output o_awvalid,
  input i_awready,
  
  output [DATA_WIDTH - 1:0] o_wdata,
  output [STRB_WIDTH - 1:0] o_wstrb,
  output o_wvalid,
  input i_wready,
  
  input [1:0] i_bresp,
  input i_bvalid,
  output o_bready,
  
  output [ADDR_WIDTH - 1:0] o_araddr,
  output [2:0] o_arprot,
  output o_arvalid,
  input i_arready,
  
  input [DATA_WIDTH - 1:0] i_rdata,
  input [1:0] i_rresp,
  input i_rvalid,
  output o_rready
  );
  
  axil_rd_cha # (
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH)
    ) axil_rd_cha (
      .aclk       (aclk),
      .anreset    (anreset),
      .aenable    (aenable),
      .i_rd_ready (i_rd_ready),
      .i_rd_addr  (i_rd_addr),
      .o_rd_valid (o_rd_valid),
      .o_rd_data  (o_rd_data),
      .o_araddr   (o_araddr),
      .o_arprot   (o_arprot),
      .o_arvalid  (o_arvalid),
      .i_arready  (i_arready),
      .i_rdata    (i_rdata),
      .i_rresp    (i_rresp),
      .i_rvalid   (i_rvalid),
      .o_rready   (o_rready)
    );
  
  axil_wr_cha # (
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH)
    ) axil_wr_cha (
      .aclk       (aclk),
      .anreset    (anreset),
      .aenable    (aenable),
      .i_wr_valid (i_wr_valid),
      .i_wr_strb  (i_wr_strb),
      .i_wr_addr  (i_wr_addr),
      .i_wr_data  (i_wr_data),
      .o_wr_ready (o_wr_ready),
      .o_awaddr   (o_awaddr),
      .o_awprot   (o_awprot), 
      .o_awvalid  (o_awvalid),
      .i_awready  (i_awready),
      .o_wdata    (o_wdata),
      .o_wstrb    (o_wstrb),
      .o_wvalid   (o_wvalid),
      .i_wready   (i_wready),
      .i_bresp    (i_bresp),
      .i_bvalid   (i_bvalid),
      .o_bready   (o_bready)
    );
  
endmodule
