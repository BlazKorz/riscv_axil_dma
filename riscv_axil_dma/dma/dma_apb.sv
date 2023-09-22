module dma_apb #(
  parameter APB_SVL = 4,
  parameter APB_ADDR_WIDTH = 16,
  parameter APB_DATA_WIDTH = 16
  )(
  input pclk,
  input pnreset,
  input penable,
  
  input i_abort,
  input i_pready [APB_SVL],
  input i_wr_full,
  input i_rd_empty,
  input i_write,
  input [$clog2(APB_SVL) - 1:0] i_sel,
  
  input [APB_DATA_WIDTH - 1:0] i_data,
  input [APB_DATA_WIDTH - 1:0] i_prdata [APB_SVL],
  
  input [APB_ADDR_WIDTH - 1:0] i_addr,
  
  output o_wr_valid,
  output o_rd_valid,
  output o_penable,
  output o_psel [APB_SVL],
  output o_pwrite,
  
  output [APB_DATA_WIDTH - 1:0] o_pwdata,
  output [APB_DATA_WIDTH - 1:0] o_data,
  
  output [APB_ADDR_WIDTH - 1:0] o_paddr
  );
  
  wire [$clog2(APB_SVL) - 1:0] dma_apb_arbiter__psel;
  wire                         dma_apb_logic__pready;
  
  dma_apb_ctrl_logic #(
    .APB_SVL        (APB_SVL),
    .APB_ADDR_WIDTH (APB_ADDR_WIDTH),
    .APB_DATA_WIDTH (APB_DATA_WIDTH)
    ) dma_apb_ctrl_logic (
      .i_pready   (i_pready),
      .i_psel     (dma_apb_arbiter__psel),
      .i_prdata   (i_prdata),
      .o_pready   (dma_apb_logic__pready),
      .o_psel     (o_psel),
      .o_prdata   (o_data)
    );
  
  dma_apb_arbiter #(
    .APB_SVL        (APB_SVL),
    .APB_ADDR_WIDTH (APB_ADDR_WIDTH),
    .APB_DATA_WIDTH (APB_DATA_WIDTH)
    ) dma_apb_arbiter (
      .pclk       (pclk),
      .pnreset    (pnreset),
      .penable    (penable),
      .i_abort    (i_abort),
      .i_pready   (dma_apb_logic__pready),
      .i_wr_full  (i_wr_full),
      .i_rd_empty (i_rd_empty),
      .i_write    (i_write),
      .i_sel      (i_sel),
      .i_data     (i_data),
      .i_addr     (i_addr),
      .o_penable  (o_penable),
      .o_wr_valid (o_wr_valid),
      .o_rd_valid (o_rd_valid),
      .o_psel     (dma_apb_arbiter__psel),
      .o_pwrite   (o_pwrite),
      .o_pwdata   (o_pwdata),
      .o_paddr    (o_paddr)
    );
  
endmodule
