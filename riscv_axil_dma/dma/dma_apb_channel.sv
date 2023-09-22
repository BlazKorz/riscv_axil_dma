module dma_apb_channel #(
  parameter APB_SVL = 4,
  parameter APB_ADDR_WIDTH = 16,
  parameter APB_FIFO_DMA2APB_ADDR_WIDTH = 5,
  parameter APB_FIFO_APB2DMA_ADDR_WIDTH = 4,
  parameter APB_DATA_WIDTH = 16,
  parameter APB_FIFO_DMA2APB_DATA_WIDTH = $clog2(APB_SVL) + APB_ADDR_WIDTH + APB_DATA_WIDTH + 1,
  parameter APB_FIFO_APB2DMA_DATA_WIDTH = APB_DATA_WIDTH
  )(
  input aclk,
  input pclk,
  input anreset,
  input pnreset,
  input aenable,
  input penable,
  
  input i_abort,
  input i_pready [APB_SVL],
  input i_wr_valid,
  input i_rd_valid,
  input i_write,
  input [$clog2(APB_SVL) - 1:0] i_sel,
  
  input [APB_DATA_WIDTH - 1:0] i_data,
  input [APB_DATA_WIDTH - 1:0] i_prdata [APB_SVL],
  
  input [APB_ADDR_WIDTH - 1:0] i_addr,
  
  output o_penable,
  output o_psel [APB_SVL],
  output o_pwrite,
  output o_wr_full,
  output o_rd_empty,
  
  output [APB_DATA_WIDTH - 1:0] o_pwdata,
  output [APB_DATA_WIDTH - 1:0] o_data,
  
  output [APB_ADDR_WIDTH - 1:0] o_paddr
  );
  
  wire                         dma_dma2apb_afifo_mem__write;
  wire                         dma_dma2apb_afifo_mem__rd_empty;
  wire [$clog2(APB_SVL) - 1:0] dma_dma2apb_afifo_mem__sel;
  wire [APB_DATA_WIDTH - 1:0]  dma_dma2apb_afifo_mem__data;
  wire [APB_ADDR_WIDTH - 1:0]  dma_dma2apb_afifo_mem__addr;
  wire                         dma_apb2dma_afifo_mem__wr_full;
  wire                         dma_advanced_peripheral_bus__wr_valid;
  wire                         dma_advanced_peripheral_bus__rd_valid;
  wire [APB_DATA_WIDTH - 1:0]  dma_advanced_peripheral_bus__data;
  
  async_fifo_mem #(
    .FIFO_ADDR_WIDTH (APB_FIFO_DMA2APB_ADDR_WIDTH),
    .FIFO_DATA_WIDTH (APB_FIFO_DMA2APB_DATA_WIDTH)
    ) dma_dma2apb_afifo_mem (
      .clk_wr     (aclk),
      .clk_rd     (pclk),
      .nreset_wr  (anreset),
      .nreset_rd  (pnreset),
      .enable_wr  (aenable),
      .enable_rd  (penable),
      .i_wr_valid (i_wr_valid),
      .i_rd_valid (dma_advanced_peripheral_bus__rd_valid),
      .i_wr_data  ({i_write,
                    i_sel,
                    i_data,
                    i_addr}),
      .o_wr_full  (o_wr_full),
      .o_rd_empty (dma_dma2apb_afifo_mem__rd_empty),
      .o_rd_data  ({dma_dma2apb_afifo_mem__write,
                    dma_dma2apb_afifo_mem__sel,
                    dma_dma2apb_afifo_mem__data, 
                    dma_dma2apb_afifo_mem__addr})
    );
  
  async_fifo_mem #(
    .FIFO_ADDR_WIDTH (APB_FIFO_APB2DMA_ADDR_WIDTH),
    .FIFO_DATA_WIDTH (APB_FIFO_APB2DMA_DATA_WIDTH)
    ) dma_apb2dma_afifo_mem (
      .clk_wr     (pclk),
      .clk_rd     (aclk),
      .nreset_wr  (pnreset),
      .nreset_rd  (anreset),
      .enable_wr  (penable),
      .enable_rd  (aenable),
      .i_wr_valid (dma_advanced_peripheral_bus__wr_valid),
      .i_rd_valid (i_rd_valid),
      .i_wr_data  (dma_advanced_peripheral_bus__data),
      .o_wr_full  (dma_apb2dma_afifo_mem__wr_full),
      .o_rd_empty (o_rd_empty),
      .o_rd_data  (o_data)
    );
  
  dma_apb #(
    .APB_SVL        (APB_SVL),
    .APB_ADDR_WIDTH (APB_ADDR_WIDTH),
    .APB_DATA_WIDTH (APB_DATA_WIDTH)
    ) dma_apb (
      .pclk       (pclk),
      .pnreset    (pnreset),
      .penable    (penable),
      .i_abort    (i_abort),
      .i_pready   (i_pready),
      .i_wr_full  (dma_apb2dma_afifo_mem__wr_full),
      .i_rd_empty (dma_dma2apb_afifo_mem__rd_empty),
      .i_write    (dma_dma2apb_afifo_mem__write),
      .i_sel      (dma_dma2apb_afifo_mem__sel),
      .i_data     (dma_dma2apb_afifo_mem__data),
      .i_prdata   (i_prdata),
      .i_addr     (dma_dma2apb_afifo_mem__addr),
      .o_wr_valid (dma_advanced_peripheral_bus__wr_valid),
      .o_rd_valid (dma_advanced_peripheral_bus__rd_valid),
      .o_penable  (o_penable),
      .o_psel     (o_psel),
      .o_pwrite   (o_pwrite),
      .o_pwdata   (o_pwdata),
      .o_data     (dma_advanced_peripheral_bus__data),
      .o_paddr    (o_paddr)
    );
  
endmodule
