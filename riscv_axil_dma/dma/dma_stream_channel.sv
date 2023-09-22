module dma_stream_channel # (
  parameter         APB_STR_CHA = 2,
  parameter integer APB_SVL [APB_STR_CHA] = {2, 4},
  parameter         APB_ADDR_WIDTH = 16,
  parameter integer APB_FIFO_DMA2APB_ADDR_WIDTH [APB_STR_CHA] = {8, 8},
  parameter integer APB_FIFO_APB2DMA_ADDR_WIDTH [APB_STR_CHA] = {4, 4},
  parameter integer APB_DATA_WIDTH [APB_STR_CHA] = {16, 8}
  )(
  input aclk,
  input pclk [APB_STR_CHA],
  input anreset,
  input pnreset [APB_STR_CHA],
  input aenable,
  input penable [APB_STR_CHA],
  
  input i_abort [APB_STR_CHA],
  input i_pready_0 [APB_SVL[0]],
  input i_pready_1 [APB_SVL[1]],
  input i_wr_valid [APB_STR_CHA],
  input i_rd_valid [APB_STR_CHA],
  input i_write [APB_STR_CHA],
  input [$clog2(APB_SVL[0]) - 1:0] i_sel_0,
  input [$clog2(APB_SVL[1]) - 1:0] i_sel_1,
  
  input [APB_DATA_WIDTH[0] - 1:0] i_data_0,
  input [APB_DATA_WIDTH[1] - 1:0] i_data_1,
  input [APB_DATA_WIDTH[0] - 1:0] i_prdata_0 [APB_SVL[0]],
  input [APB_DATA_WIDTH[1] - 1:0] i_prdata_1 [APB_SVL[1]],
  
  input [APB_ADDR_WIDTH - 1:0] i_addr [APB_STR_CHA],
  
  output o_penable [APB_STR_CHA],
  output o_psel_0 [APB_SVL[0]],
  output o_psel_1 [APB_SVL[1]],
  output o_pwrite [APB_STR_CHA],
  output o_wr_full [APB_STR_CHA],
  output o_rd_empty [APB_STR_CHA],
  
  output [APB_DATA_WIDTH[0] - 1:0] o_pwdata_0,
  output [APB_DATA_WIDTH[1] - 1:0] o_pwdata_1,
  output [APB_DATA_WIDTH[0] - 1:0] o_data_0,
  output [APB_DATA_WIDTH[1] - 1:0] o_data_1,
  
  output [APB_ADDR_WIDTH - 1:0] o_paddr [APB_STR_CHA]
  );
  
  dma_apb_channel #(
    .APB_SVL                     (APB_SVL[0]),
    .APB_ADDR_WIDTH              (APB_ADDR_WIDTH),
    .APB_FIFO_DMA2APB_ADDR_WIDTH (APB_FIFO_DMA2APB_ADDR_WIDTH[0]),
    .APB_FIFO_APB2DMA_ADDR_WIDTH (APB_FIFO_APB2DMA_ADDR_WIDTH[0]),
    .APB_DATA_WIDTH              (APB_DATA_WIDTH[0])
    ) dma_apb_channel_0 (
      .aclk       (aclk),
      .pclk       (pclk[0]),
      .anreset    (anreset),
      .pnreset    (pnreset[0]),
      .aenable    (aenable),
      .penable    (penable[0]),
      .i_abort    (i_abort[0]),
      .i_pready   (i_pready_0),
      .i_wr_valid (i_wr_valid[0]),
      .i_rd_valid (i_rd_valid[0]),
      .i_write    (i_write[0]),
      .i_sel      (i_sel_0),
      .i_data     (i_data_0),
      .i_prdata   (i_prdata_0),
      .i_addr     (i_addr[0]),
      .o_penable  (o_penable[0]),
      .o_psel     (o_psel_0),
      .o_pwrite   (o_pwrite[0]),
      .o_wr_full  (o_wr_full[0]),
      .o_rd_empty (o_rd_empty[0]),
      .o_pwdata   (o_pwdata_0),
      .o_data     (o_data_0),
      .o_paddr    (o_paddr[0])
    );
  
  dma_apb_channel #(
    .APB_SVL                     (APB_SVL[1]),
    .APB_ADDR_WIDTH              (APB_ADDR_WIDTH),
    .APB_FIFO_DMA2APB_ADDR_WIDTH (APB_FIFO_DMA2APB_ADDR_WIDTH[1]),
    .APB_FIFO_APB2DMA_ADDR_WIDTH (APB_FIFO_APB2DMA_ADDR_WIDTH[1]),
    .APB_DATA_WIDTH              (APB_DATA_WIDTH[1])
    ) dma_apb_channel_1 (
      .aclk       (aclk),
      .pclk       (pclk[1]),
      .anreset    (anreset),
      .pnreset    (pnreset[1]),
      .aenable    (aenable),
      .penable    (penable[1]),
      .i_abort    (i_abort[1]),
      .i_pready   (i_pready_1),
      .i_wr_valid (i_wr_valid[1]),
      .i_rd_valid (i_rd_valid[1]),
      .i_write    (i_write[1]),
      .i_sel      (i_sel_1),
      .i_data     (i_data_1),
      .i_prdata   (i_prdata_1),
      .i_addr     (i_addr[1]),
      .o_penable  (o_penable[1]),
      .o_psel     (o_psel_1),
      .o_pwrite   (o_pwrite[1]),
      .o_wr_full  (o_wr_full[1]),
      .o_rd_empty (o_rd_empty[1]),
      .o_pwdata   (o_pwdata_1),
      .o_data     (o_data_1),
      .o_paddr    (o_paddr[1])
    );
  
endmodule
