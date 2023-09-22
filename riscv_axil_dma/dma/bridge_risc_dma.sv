module bridge_risc_dma #(
  parameter ADDR_WIDTH = 16,
  parameter DATA_WIDTH = 64
  )(
  input risc_clk,
  input risc_nreset,
  input risc_enable,
  
  input dma_clk,
  input dma_nreset,
  input dma_enable,
  
  input i_desc_wr,
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
  output o_desc_wready,
  
  input i_desc_rd,
  output o_desc_endian,
  output o_desc_write,
  output [1:0] o_desc_ch_sel,
  output [7:0] o_desc_len,
  output [2:0] o_desc_size,
  output [1:0] o_desc_burst,
  output [3:0] o_desc_sel,
  output [7:0] o_desc_id,
  output [ADDR_WIDTH - 1:0] o_desc_dma_addr,
  output [ADDR_WIDTH - 1:0] o_desc_mem_addr,
  output o_desc_rready,
  
  input i_resp_wr,
  output [7:0] i_resp_desc_id,
  output [1:0] i_resp_ch_sel,
  output o_resp_wready,
  
  input i_resp_rd,
  output [7:0] o_resp_desc_id,
  output [1:0] o_resp_ch_sel,
  output o_resp_rready
  );
  
  wire dma_risc2dma_afifo_mem__wr_full;
  wire dma_risc2dma_afifo_mem__rd_empty;
  
  wire dma_dma2risc_afifo_mem__wr_full;
  wire dma_dma2risc_afifo_mem__rd_empty;
  
  async_fifo_mem #(
    .FIFO_ADDR_WIDTH (4),
    .FIFO_DATA_WIDTH (61)
    ) dma_risc2dma_afifo_mem (
      .clk_wr     (risc_clk),
      .clk_rd     (dma_clk),
      .nreset_wr  (risc_nreset),
      .nreset_rd  (dma_nreset),
      .enable_wr  (risc_enable),
      .enable_rd  (dma_enable),
      .i_wr_valid (i_desc_wr),
      .i_rd_valid (i_desc_rd),
      .i_wr_data  ({i_desc_endian,
                    i_desc_write,
                    i_desc_ch_sel,
                    i_desc_len,
                    i_desc_size,
                    i_desc_burst,
                    i_desc_sel,
                    i_desc_id,
                    i_desc_dma_addr,
                    i_desc_mem_addr}),
      .o_wr_full  (dma_risc2dma_afifo_mem__wr_full),
      .o_rd_empty (dma_risc2dma_afifo_mem__rd_empty),
      .o_rd_data  ({o_desc_endian,
                    o_desc_write,
                    o_desc_ch_sel,
                    o_desc_len,
                    o_desc_size,
                    o_desc_burst,
                    o_desc_sel,
                    o_desc_id,
                    o_desc_dma_addr,
                    o_desc_mem_addr})
    );
  
  async_fifo_mem #(
    .FIFO_ADDR_WIDTH (4),
    .FIFO_DATA_WIDTH (10)
    ) dma_dma2risc_afifo_mem (
      .clk_wr     (dma_clk),
      .clk_rd     (risc_clk),
      .nreset_wr  (dma_nreset),
      .nreset_rd  (risc_nreset),
      .enable_wr  (dma_enable),
      .enable_rd  (risc_enable),
      .i_wr_valid (i_resp_wr),
      .i_rd_valid (i_resp_rd),
      .i_wr_data  ({i_resp_ch_sel, 
                    i_resp_desc_id}),
      .o_wr_full  (dma_dma2risc_afifo_mem__wr_full),
      .o_rd_empty (dma_dma2risc_afifo_mem__rd_empty),
      .o_rd_data  ({o_resp_ch_sel,
                    o_resp_desc_id})
    );
  
  assign o_desc_wready = ~dma_risc2dma_afifo_mem__wr_full;
  assign o_resp_wready = ~dma_dma2risc_afifo_mem__wr_full;
  assign o_desc_rready = (dma_nreset || risc_nreset) ? ~dma_risc2dma_afifo_mem__rd_empty : 1'h0;
  assign o_resp_rready = (dma_nreset || risc_nreset) ? ~dma_dma2risc_afifo_mem__rd_empty : 1'h0;
  
endmodule
