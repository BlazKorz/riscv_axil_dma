import common_cells_pkg::*;

module async_fifo_mem #(
  parameter FIFO_ADDR_WIDTH = 16,
  parameter FIFO_DATA_WIDTH = 64
  )(
  input clk_wr,
  input clk_rd,
  input nreset_wr,
  input nreset_rd,
  input enable_wr,
  input enable_rd,
  
  input i_wr_valid,
  input i_rd_valid,
  
  input [FIFO_DATA_WIDTH - 1:0] i_wr_data,
  
  output o_wr_full,
  output o_rd_empty,
  
  output [FIFO_DATA_WIDTH - 1:0] o_rd_data
  );
  
  localparam DMA_FIFO_DEPTH = 1 << FIFO_ADDR_WIDTH;
  
  wire                     wr_synq_en_c;
  reg  [FIFO_ADDR_WIDTH:0] sync_rd_r [2];
  
  wire                     rd_synq_en_c;
  reg  [FIFO_ADDR_WIDTH:0] sync_wr_r [2];
  
  wire                     wr_addr_ptr_en_c;
  wire [FIFO_ADDR_WIDTH:0] wr_addr_c;
  reg  [FIFO_ADDR_WIDTH:0] wr_addr_r;
  wire [FIFO_ADDR_WIDTH:0] wr_ptr_c;
  reg  [FIFO_ADDR_WIDTH:0] wr_ptr_r;
  
  wire                     rd_addr_ptr_en_c;
  wire [FIFO_ADDR_WIDTH:0] rd_addr_c;
  reg  [FIFO_ADDR_WIDTH:0] rd_addr_r;
  wire [FIFO_ADDR_WIDTH:0] rd_ptr_c;
  reg  [FIFO_ADDR_WIDTH:0] rd_ptr_r;
  
  wire wr_full_en_c;
  wire wr_full_c;
  reg  wr_full_r;
  
  wire rd_empty_en_c;
  wire rd_empty_c;
  reg  rd_empty_r;
  
  wire [FIFO_DATA_WIDTH - 1:0] rd_mem;
  
  assign wr_synq_en_c = enable_wr;
 `RTL_REG_ASYNC (clk_wr, nreset_wr, wr_synq_en_c, rd_ptr_r, sync_rd_r[0], FIFO_ADDR_WIDTH);
 `RTL_REG_ASYNC (clk_wr, nreset_wr, wr_synq_en_c, sync_rd_r[0], sync_rd_r[1], FIFO_ADDR_WIDTH);
  
  assign wr_full_en_c = enable_wr;
  assign wr_full_c = (wr_ptr_c == {~sync_rd_r[1][FIFO_ADDR_WIDTH:FIFO_ADDR_WIDTH - 1], 
                                    sync_rd_r[1][FIFO_ADDR_WIDTH - 2:0]});
 `RTL_REG_ASYNC (clk_wr, nreset_wr, wr_full_en_c, wr_full_c, wr_full_r, 1);
  
  assign wr_addr_ptr_en_c = enable_wr;
  assign wr_addr_c = wr_addr_r + (i_wr_valid & ~wr_full_r);
  assign wr_ptr_c = (wr_addr_c >> 1) ^ wr_addr_c;
 `RTL_REG_ASYNC (clk_wr, nreset_wr, wr_addr_ptr_en_c, wr_addr_c, wr_addr_r, FIFO_ADDR_WIDTH);
 `RTL_REG_ASYNC (clk_wr, nreset_wr, wr_addr_ptr_en_c, wr_ptr_c, wr_ptr_r, FIFO_ADDR_WIDTH);
  
  assign rd_synq_en_c = enable_rd;
 `RTL_REG_ASYNC (clk_rd, nreset_rd, rd_synq_en_c, wr_ptr_r, sync_wr_r[0], FIFO_ADDR_WIDTH);
 `RTL_REG_ASYNC (clk_rd, nreset_rd, rd_synq_en_c, sync_wr_r[0], sync_wr_r[1], FIFO_ADDR_WIDTH);
  
  assign rd_empty_en_c = enable_rd;
  assign rd_empty_c = (rd_ptr_c == sync_wr_r[1]);
 `RTL_REG_ASYNC (clk_rd, nreset_rd, rd_empty_en_c, rd_empty_c, rd_empty_r, 1);
  
  assign rd_addr_ptr_en_c = enable_rd;
  assign rd_addr_c = rd_addr_r + (i_rd_valid & ~rd_empty_r);
  assign rd_ptr_c = (rd_addr_c >> 1) ^ rd_addr_c;
 `RTL_REG_ASYNC (clk_rd, nreset_rd, rd_addr_ptr_en_c, rd_addr_c, rd_addr_r, FIFO_ADDR_WIDTH);
 `RTL_REG_ASYNC (clk_rd, nreset_rd, rd_addr_ptr_en_c, rd_ptr_c, rd_ptr_r, FIFO_ADDR_WIDTH);
  
  assign wr_mem_c = i_wr_valid && !wr_full_r && enable_wr;
 `RTL_RAM (clk_wr, wr_mem_c, i_wr_data, wr_addr_r, rd_addr_r, rd_mem, FIFO_DATA_WIDTH, FIFO_ADDR_WIDTH, DMA_FIFO_DEPTH);
  
  assign o_wr_full = wr_full_r;
  assign o_rd_empty = rd_empty_r;
  assign o_rd_data = rd_mem;
  
endmodule
