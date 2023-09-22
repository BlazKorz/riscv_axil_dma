module dma_multi_channel_scheduler #(
  parameter         APB_STR_CHA = 2,
  parameter integer APB_SVL [APB_STR_CHA] = {2, 4},
  parameter         ADDR_WIDTH = 16,
  parameter         APB_ADDR_WIDTH = 16,
  parameter integer APB_DATA_WIDTH [APB_STR_CHA] = {16, 8},
  parameter         DATA_WIDTH = 64,
  parameter         STRB_WIDTH = (DATA_WIDTH / 8)
  )(
  input aclk,
  input anreset,
  input aenable,
  
  input i_abort [APB_STR_CHA],
  
  output o_axil_wvalid,
  output [STRB_WIDTH - 1:0] o_axil_wstrb,
  output [DATA_WIDTH - 1:0] o_axil_wdata,
  output [ADDR_WIDTH - 1:0] o_axil_waddr,
  input i_axil_wready,
  output o_axil_rready,
  output [ADDR_WIDTH - 1:0] o_axil_raddr,
  input i_axil_rvalid,
  input [DATA_WIDTH - 1:0] i_axil_rdata,
  
  output o_desc_rd,
  input i_desc_endian,
  input i_desc_write,
  input [1:0] i_desc_ch_sel,
  input [7:0] i_desc_len,
  input [2:0] i_desc_size,
  input [1:0] i_desc_burst,
  input [3:0] i_desc_sel,
  input [7:0] i_desc_id,
  input [ADDR_WIDTH - 1:0] i_desc_dma_addr,
  input [ADDR_WIDTH - 1:0] i_desc_mem_addr,
  input i_desc_rready,
  
  output o_resp_wr,
  output [7:0] o_resp_desc_id,
  output [1:0] o_resp_ch_sel,
  input i_resp_wready,
  
  output o_dma2apb_wvalid [APB_STR_CHA],
  output o_apb2dma_rready [APB_STR_CHA],
  output o_apb_pwrite [APB_STR_CHA],
  output [$clog2(APB_SVL[0]) - 1:0] o_apb_psel_0,
  output [$clog2(APB_SVL[1]) - 1:0] o_apb_psel_1,
  output [APB_DATA_WIDTH[0] - 1:0] o_apb_pdata_0,
  output [APB_DATA_WIDTH[1] - 1:0] o_apb_pdata_1,
  output [APB_ADDR_WIDTH - 1:0] o_apb_paddr [APB_STR_CHA],
  input i_dma2apb_full [APB_STR_CHA],
  input i_apb2dma_empty [APB_STR_CHA],
  input [APB_DATA_WIDTH[0] - 1:0] i_apb_pdata_0,
  input [APB_DATA_WIDTH[1] - 1:0] i_apb_pdata_1 
  );
  
  wire                    dma_axil_arbiter__axil_wready [APB_STR_CHA];
  wire                    dma_axil_arbiter__axil_rvalid [APB_STR_CHA];
  wire [DATA_WIDTH - 1:0] dma_axil_arbiter__axil_rdata [APB_STR_CHA];
  wire                    dma_desc_arbiter__desc_rready [APB_STR_CHA];
  wire                    dma_desc_arbiter__resp_wready [APB_STR_CHA];
  wire                    dma_apb_channel_arbiter__axil_wvalid [APB_STR_CHA];
  wire [STRB_WIDTH - 1:0] dma_apb_channel_arbiter__axil_wstrb [APB_STR_CHA];
  wire [DATA_WIDTH - 1:0] dma_apb_channel_arbiter__axil_wdata [APB_STR_CHA];
  wire [ADDR_WIDTH - 1:0] dma_apb_channel_arbiter__axil_waddr [APB_STR_CHA];
  wire                    dma_apb_channel_arbiter__axil_rready [APB_STR_CHA];
  wire [ADDR_WIDTH - 1:0] dma_apb_channel_arbiter__axil_raddr [APB_STR_CHA];
  wire                    dma_apb_channel_arbiter__desc_rd [APB_STR_CHA];  
  wire                    dma_apb_channel_arbiter__resp_wr [APB_STR_CHA];   
  wire [7:0]              dma_apb_channel_arbiter__resp_desc_id [APB_STR_CHA];
  
  dma_axil_arbiter #(
    .APB_STR_CHA    (APB_STR_CHA),
    .ADDR_WIDTH     (ADDR_WIDTH),
    .DATA_WIDTH     (DATA_WIDTH),
    .STRB_WIDTH     (STRB_WIDTH)
    ) dma_axil_arbiter (
      .aclk             (aclk),
      .anreset          (anreset),
      .aenable          (aenable),
      .i_abort          (i_abort),
      .o_axil_wvalid    (o_axil_wvalid),
      .o_axil_wstrb     (o_axil_wstrb),
      .o_axil_wdata     (o_axil_wdata),
      .o_axil_waddr     (o_axil_waddr),
      .i_axil_wready    (i_axil_wready),
      .o_axil_rready    (o_axil_rready),
      .o_axil_raddr     (o_axil_raddr),
      .i_axil_rvalid    (i_axil_rvalid),
      .i_axil_rdata     (i_axil_rdata),
      .i_axil_wvalid    (dma_apb_channel_arbiter__axil_wvalid),
      .i_axil_wstrb     (dma_apb_channel_arbiter__axil_wstrb),
      .i_axil_wdata     (dma_apb_channel_arbiter__axil_wdata),
      .i_axil_waddr     (dma_apb_channel_arbiter__axil_waddr),
      .o_axil_wready    (dma_axil_arbiter__axil_wready),
      .i_axil_rready    (dma_apb_channel_arbiter__axil_rready),
      .i_axil_raddr     (dma_apb_channel_arbiter__axil_raddr),
      .o_axil_rvalid    (dma_axil_arbiter__axil_rvalid),
      .o_axil_rdata     (dma_axil_arbiter__axil_rdata)
    );
  
  dma_desc_arbiter #(
    .APB_STR_CHA    (APB_STR_CHA)
    ) dma_desc_arbiter (
      .aclk             (aclk),
      .anreset          (anreset),
      .aenable          (aenable),
      .i_abort          (i_abort),
      .i_desc_ch_sel    (i_desc_ch_sel),
      .i_desc_rready    (i_desc_rready),
      .o_desc_rd        (o_desc_rd),
      .o_resp_wr        (o_resp_wr),
      .o_resp_desc_id   (o_resp_desc_id),
      .o_resp_ch_sel    (o_resp_ch_sel),
      .i_resp_wready    (i_resp_wready),
      .o_desc_rready    (dma_desc_arbiter__desc_rready),
      .i_desc_rd        (dma_apb_channel_arbiter__desc_rd),
      .i_resp_wr        (dma_apb_channel_arbiter__resp_wr),
      .i_resp_desc_id   (dma_apb_channel_arbiter__resp_desc_id),
      .o_resp_wready    (dma_desc_arbiter__resp_wready)
    );
  
  dma_apb_channel_arbiter #(
    .APB_SVL        (APB_SVL[0]),
    .ADDR_WIDTH     (ADDR_WIDTH),
    .APB_ADDR_WIDTH (APB_ADDR_WIDTH),
    .APB_DATA_WIDTH (APB_DATA_WIDTH[0]),
    .DATA_WIDTH     (DATA_WIDTH)
    ) dma_apb_channel_arbiter_0 (
      .clk              (aclk),
      .nreset           (anreset),
      .enable           (aenable),
      .i_abort          (i_abort[0]),
      .o_axil_wvalid    (dma_apb_channel_arbiter__axil_wvalid[0]),
      .o_axil_wstrb     (dma_apb_channel_arbiter__axil_wstrb[0]),
      .o_axil_wdata     (dma_apb_channel_arbiter__axil_wdata[0]),
      .o_axil_waddr     (dma_apb_channel_arbiter__axil_waddr[0]),
      .i_axil_wready    (dma_axil_arbiter__axil_wready[0]),
      .o_axil_rready    (dma_apb_channel_arbiter__axil_rready[0]),
      .o_axil_raddr     (dma_apb_channel_arbiter__axil_raddr[0]),
      .i_axil_rvalid    (dma_axil_arbiter__axil_rvalid[0]),
      .i_axil_rdata     (dma_axil_arbiter__axil_rdata[0]),
      .o_desc_rd        (dma_apb_channel_arbiter__desc_rd[0]),
      .i_desc_endian    (i_desc_endian),
      .i_desc_write     (i_desc_write),
      .i_desc_len       (i_desc_len),
      .i_desc_size      (i_desc_size),
      .i_desc_burst     (i_desc_burst),
      .i_desc_sel       (i_desc_sel),
      .i_desc_id        (i_desc_id),
      .i_desc_dma_addr  (i_desc_dma_addr),
      .i_desc_mem_addr  (i_desc_mem_addr),
      .i_desc_rready    (dma_desc_arbiter__desc_rready[0]),
      .o_resp_wr        (dma_apb_channel_arbiter__resp_wr[0]),
      .o_resp_desc_id   (dma_apb_channel_arbiter__resp_desc_id[0]),
      .i_resp_wready    (dma_desc_arbiter__resp_wready[0]),
      .i_dma2apb_full   (i_dma2apb_full[0]),
      .i_apb2dma_empty  (i_apb2dma_empty[0]),
      .i_apb_pdata      (i_apb_pdata_0),
      .o_dma2apb_wvalid (o_dma2apb_wvalid[0]),
      .o_apb2dma_rready (o_apb2dma_rready[0]),
      .o_apb_pwrite     (o_apb_pwrite[0]),
      .o_apb_psel       (o_apb_psel_0),
      .o_apb_pdata      (o_apb_pdata_0),
      .o_apb_paddr      (o_apb_paddr[0])
    );
  
  dma_apb_channel_arbiter #(
    .APB_SVL        (APB_SVL[1]),
    .ADDR_WIDTH     (ADDR_WIDTH),
    .APB_ADDR_WIDTH (APB_ADDR_WIDTH),
    .APB_DATA_WIDTH (APB_DATA_WIDTH[1]),
    .DATA_WIDTH     (DATA_WIDTH)
    ) dma_apb_channel_arbiter_1 (
      .clk              (aclk),
      .nreset           (anreset),
      .enable           (aenable),
      .i_abort          (i_abort[1]),
      .o_axil_wvalid    (dma_apb_channel_arbiter__axil_wvalid[1]),
      .o_axil_wstrb     (dma_apb_channel_arbiter__axil_wstrb[1]),
      .o_axil_wdata     (dma_apb_channel_arbiter__axil_wdata[1]),
      .o_axil_waddr     (dma_apb_channel_arbiter__axil_waddr[1]),
      .i_axil_wready    (dma_axil_arbiter__axil_wready[1]),
      .o_axil_rready    (dma_apb_channel_arbiter__axil_rready[1]),
      .o_axil_raddr     (dma_apb_channel_arbiter__axil_raddr[1]),
      .i_axil_rvalid    (dma_axil_arbiter__axil_rvalid[1]),
      .i_axil_rdata     (dma_axil_arbiter__axil_rdata[1]),
      .o_desc_rd        (dma_apb_channel_arbiter__desc_rd[1]),
      .i_desc_endian    (i_desc_endian),
      .i_desc_write     (i_desc_write),
      .i_desc_len       (i_desc_len),
      .i_desc_size      (i_desc_size),
      .i_desc_burst     (i_desc_burst),
      .i_desc_sel       (i_desc_sel),
      .i_desc_id        (i_desc_id),
      .i_desc_dma_addr  (i_desc_dma_addr),
      .i_desc_mem_addr  (i_desc_mem_addr),
      .i_desc_rready    (dma_desc_arbiter__desc_rready[1]),
      .o_resp_wr        (dma_apb_channel_arbiter__resp_wr[1]),
      .o_resp_desc_id   (dma_apb_channel_arbiter__resp_desc_id[1]),
      .i_resp_wready    (dma_desc_arbiter__resp_wready[1]),
      .i_dma2apb_full   (i_dma2apb_full[1]),
      .i_apb2dma_empty  (i_apb2dma_empty[1]),
      .i_apb_pdata      (i_apb_pdata_1),
      .o_dma2apb_wvalid (o_dma2apb_wvalid[1]),
      .o_apb2dma_rready (o_apb2dma_rready[1]),
      .o_apb_pwrite     (o_apb_pwrite[1]),
      .o_apb_psel       (o_apb_psel_1),
      .o_apb_pdata      (o_apb_pdata_1),
      .o_apb_paddr      (o_apb_paddr[1])
    );
  
endmodule
