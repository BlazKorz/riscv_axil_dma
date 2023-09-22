import common_cells_pkg::*;

module axil_dma #(
  parameter         APB_STR_CHA = 2,
  parameter integer APB_SVL [APB_STR_CHA] = {2, 4},
  parameter         ADDR_WIDTH = 16,
  parameter         APB_ADDR_WIDTH = 16,
  parameter integer APB_FIFO_DMA2APB_ADDR_WIDTH [APB_STR_CHA] = {5, 5},
  parameter integer APB_FIFO_APB2DMA_ADDR_WIDTH [APB_STR_CHA] = {4, 4},
  parameter integer APB_DATA_WIDTH [APB_STR_CHA] = {16, 8},
  parameter         DATA_WIDTH = 64,
  parameter         STRB_WIDTH = (DATA_WIDTH / 8)
  )(
  input aclk,
  input pclk [APB_STR_CHA],
  input anreset,
  input pnreset [APB_STR_CHA],
  input aenable,
  input penable [APB_STR_CHA],
  
  input i_abort [APB_STR_CHA],
  
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
  output o_rready,
  
  input i_pready_0 [APB_SVL[0]],
  input i_pready_1 [APB_SVL[1]],
  input [APB_DATA_WIDTH[0] - 1:0] i_prdata_0 [APB_SVL[0]],
  input [APB_DATA_WIDTH[1] - 1:0] i_prdata_1 [APB_SVL[1]],
  output o_penable [APB_STR_CHA],
  output o_psel_0 [APB_SVL[0]],
  output o_psel_1 [APB_SVL[1]],
  output o_pwrite [APB_STR_CHA],
  output [APB_DATA_WIDTH[0] - 1:0] o_pwdata_0,
  output [APB_DATA_WIDTH[1] - 1:0] o_pwdata_1,
  output [APB_ADDR_WIDTH - 1:0] o_paddr [APB_STR_CHA]
  );
  
  wire                            dma_multi_channel_scheduler__axil_wvalid;
  wire [STRB_WIDTH - 1:0]         dma_multi_channel_scheduler__axil_wstrb;
  wire [DATA_WIDTH - 1:0]         dma_multi_channel_scheduler__axil_wdata;
  wire [ADDR_WIDTH - 1:0]         dma_multi_channel_scheduler__axil_waddr;
  wire                            dma_multi_channel_scheduler__axil_rready;
  wire [ADDR_WIDTH - 1:0]         dma_multi_channel_scheduler__axil_raddr;
  wire                            dma_multi_channel_scheduler__dma2apb_wvalid [APB_STR_CHA];
  wire                            dma_multi_channel_scheduler__apb2dma_rready [APB_STR_CHA];
  wire                            dma_multi_channel_scheduler__apb_pwrite [APB_STR_CHA];
  wire [$clog2(APB_SVL[0]) - 1:0] dma_multi_channel_scheduler__apb_psel_0;
  wire [$clog2(APB_SVL[1]) - 1:0] dma_multi_channel_scheduler__apb_psel_1;
  wire [APB_DATA_WIDTH[0] - 1:0]  dma_multi_channel_scheduler__apb_pdata_0;
  wire [APB_DATA_WIDTH[1] - 1:0]  dma_multi_channel_scheduler__apb_pdata_1;
  wire [APB_ADDR_WIDTH - 1:0]     dma_multi_channel_scheduler__apb_paddr [APB_STR_CHA];
  wire                            dma_stream_channel__dma2apb_full [APB_STR_CHA];
  wire                            dma_stream_channel__apb2dma_empty [APB_STR_CHA];
  wire [APB_DATA_WIDTH[0] - 1:0]  dma_stream_channel__pdata_0;
  wire [APB_DATA_WIDTH[1] - 1:0]  dma_stream_channel__pdata_1;
  wire                            axil_if__wr_ready;
  wire                            axil_if__rd_valid;
  wire [DATA_WIDTH - 1:0]         axil_if__rd_data;
  
  axil_if # (
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH)
    ) axil_dma_if (
      .aclk             (aclk),
      .anreset          (anreset),
      .aenable          (aenable),
      .i_wr_valid       (dma_multi_channel_scheduler__axil_wvalid),
      .i_wr_strb        (dma_multi_channel_scheduler__axil_wstrb),
      .i_wr_data        (dma_multi_channel_scheduler__axil_wdata),
      .i_wr_addr        (dma_multi_channel_scheduler__axil_waddr),
      .o_wr_ready       (axil_if__wr_ready),
      .i_rd_ready       (dma_multi_channel_scheduler__axil_rready),
      .i_rd_addr        (dma_multi_channel_scheduler__axil_raddr),
      .o_rd_valid       (axil_if__rd_valid),
      .o_rd_data        (axil_if__rd_data),
      .o_awaddr         (o_awaddr),
      .o_awprot         (o_awprot),
      .o_awvalid        (o_awvalid),
      .i_awready        (i_awready),
      .o_wdata          (o_wdata),
      .o_wstrb          (o_wstrb),
      .o_wvalid         (o_wvalid),
      .i_wready         (i_wready),
      .i_bresp          (i_bresp),
      .i_bvalid         (i_bvalid),
      .o_bready         (o_bready),
      .o_araddr         (o_araddr),
      .o_arprot         (o_arprot),
      .o_arvalid        (o_arvalid),
      .i_arready        (i_arready),
      .i_rdata          (i_rdata),
      .i_rresp          (i_rresp),
      .i_rvalid         (i_rvalid),
      .o_rready         (o_rready)
    );
  
  dma_multi_channel_scheduler #(
    .APB_STR_CHA    (APB_STR_CHA),
    .APB_SVL        (APB_SVL),
    .ADDR_WIDTH     (ADDR_WIDTH),
    .APB_ADDR_WIDTH (APB_ADDR_WIDTH),
    .APB_DATA_WIDTH (APB_DATA_WIDTH),
    .DATA_WIDTH     (DATA_WIDTH)
    ) dma_multi_channel_scheduler (
      .aclk             (aclk),
      .anreset          (anreset),
      .aenable          (aenable),
      .i_abort          (i_abort),
      .o_axil_wvalid    (dma_multi_channel_scheduler__axil_wvalid),
      .o_axil_wstrb     (dma_multi_channel_scheduler__axil_wstrb),
      .o_axil_wdata     (dma_multi_channel_scheduler__axil_wdata),
      .o_axil_waddr     (dma_multi_channel_scheduler__axil_waddr),
      .i_axil_wready    (axil_if__wr_ready),
      .o_axil_rready    (dma_multi_channel_scheduler__axil_rready),
      .o_axil_raddr     (dma_multi_channel_scheduler__axil_raddr),
      .i_axil_rvalid    (axil_if__rd_valid),
      .i_axil_rdata     (axil_if__rd_data),
      .o_desc_rd        (o_desc_rd),
      .i_desc_endian    (i_desc_endian),
      .i_desc_write     (i_desc_write),
      .i_desc_ch_sel    (i_desc_ch_sel),
      .i_desc_len       (i_desc_len),
      .i_desc_size      (i_desc_size),
      .i_desc_burst     (i_desc_burst),
      .i_desc_sel       (i_desc_sel),
      .i_desc_id        (i_desc_id),
      .i_desc_dma_addr  (i_desc_dma_addr),
      .i_desc_mem_addr  (i_desc_mem_addr),
      .i_desc_rready    (i_desc_rready),
      .o_resp_wr        (o_resp_wr),
      .o_resp_desc_id   (o_resp_desc_id),
      .o_resp_ch_sel    (o_resp_ch_sel),
      .i_resp_wready    (i_resp_wready),
      .o_dma2apb_wvalid (dma_multi_channel_scheduler__dma2apb_wvalid),
      .o_apb2dma_rready (dma_multi_channel_scheduler__apb2dma_rready),
      .o_apb_pwrite     (dma_multi_channel_scheduler__apb_pwrite),
      .o_apb_psel_0     (dma_multi_channel_scheduler__apb_psel_0),
      .o_apb_psel_1     (dma_multi_channel_scheduler__apb_psel_1),
      .o_apb_pdata_0    (dma_multi_channel_scheduler__apb_pdata_0),
      .o_apb_pdata_1    (dma_multi_channel_scheduler__apb_pdata_1),
      .o_apb_paddr      (dma_multi_channel_scheduler__apb_paddr),
      .i_dma2apb_full   (dma_stream_channel__dma2apb_full),
      .i_apb2dma_empty  (dma_stream_channel__apb2dma_empty),
      .i_apb_pdata_0    (dma_stream_channel__pdata_0),
      .i_apb_pdata_1    (dma_stream_channel__pdata_1)
    );
  
  dma_stream_channel #(
    .APB_STR_CHA                 (APB_STR_CHA),
    .APB_SVL                     (APB_SVL),
    .APB_ADDR_WIDTH              (APB_ADDR_WIDTH),
    .APB_FIFO_DMA2APB_ADDR_WIDTH (APB_FIFO_DMA2APB_ADDR_WIDTH),
    .APB_FIFO_APB2DMA_ADDR_WIDTH (APB_FIFO_APB2DMA_ADDR_WIDTH),
    .APB_DATA_WIDTH              (APB_DATA_WIDTH)
    ) dma_stream_channel (
      .aclk             (aclk),
      .pclk             (pclk),
      .anreset          (anreset),
      .pnreset          (pnreset),
      .aenable          (aenable),
      .penable          (penable),
      .i_abort          (i_abort),
      .i_pready_0       (i_pready_0),
      .i_pready_1       (i_pready_1),
      .i_wr_valid       (dma_multi_channel_scheduler__dma2apb_wvalid),
      .i_rd_valid       (dma_multi_channel_scheduler__apb2dma_rready),
      .i_write          (dma_multi_channel_scheduler__apb_pwrite),
      .i_sel_0          (dma_multi_channel_scheduler__apb_psel_0),
      .i_sel_1          (dma_multi_channel_scheduler__apb_psel_1),
      .i_data_0         (dma_multi_channel_scheduler__apb_pdata_0),
      .i_data_1         (dma_multi_channel_scheduler__apb_pdata_1),
      .i_prdata_0       (i_prdata_0),
      .i_prdata_1       (i_prdata_1),
      .i_addr           (dma_multi_channel_scheduler__apb_paddr),
      .o_penable        (o_penable),
      .o_psel_0         (o_psel_0),
      .o_psel_1         (o_psel_1),
      .o_pwrite         (o_pwrite),
      .o_wr_full        (dma_stream_channel__dma2apb_full),
      .o_rd_empty       (dma_stream_channel__apb2dma_empty),
      .o_pwdata_0       (o_pwdata_0),
      .o_pwdata_1       (o_pwdata_1),
      .o_data_0         (dma_stream_channel__pdata_0),
      .o_data_1         (dma_stream_channel__pdata_1),
      .o_paddr          (o_paddr)
    );
  
endmodule