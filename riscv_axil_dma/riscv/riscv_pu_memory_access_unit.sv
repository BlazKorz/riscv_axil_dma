import riscv_pkg::*;

module riscv_pu_memory_access_unit #(
  parameter ADDR_WIDTH = 64,
  parameter DATA_WIDTH = 64,
  parameter STRB_WIDTH = DATA_WIDTH / 8
  )(
  input clk,
  input nreset,
  input enable,
  
  input i_stall,
  input i_flush,
  
  input [2:0] i_width,
  input i_rd_write,
  input i_read,
  input i_write,
  input i_wb_src,
  input i_valid_instr,
  input i_mem_wr_ready,
  input i_mem_rd_valid,
  input i_desc_wready,
  input i_resp_rready,
  
  input [DATA_WIDTH - 1:0] i_alu_data,
  input [DATA_WIDTH - 1:0] i_rs2_data,
  input [9:0] i_resp_data,
  input [DATA_WIDTH - 1:0] i_mem_rd_data,
  
  input [4:0] i_rd_addr,
  
  output o_rd_write,
  output o_mem_rd_ready,
  output o_mem_wr_valid,
  output o_desc_wr,
  output o_resp_rd,
  output o_valid_instr,
  output o_flush,
  
  output [DATA_WIDTH - 1:0] o_mem_wr_data,
  output [60:0] o_desc_data,
  output [DATA_WIDTH - 1:0] o_rd_write_data,
  output [STRB_WIDTH - 1:0] o_mem_wr_strb,
  
  output [ADDR_WIDTH - 1:0] o_mem_addr,
  output [4:0] o_rd_addr
  );
  
  wire [DATA_WIDTH - 1:0] riscv_mem_adapter__rs2_data;
  wire [DATA_WIDTH - 1:0] riscv_mem_adapter__mem_rd_data;
  wire [STRB_WIDTH - 1:0] riscv_mem_adapter__mem_wr_strb;
  
  riscv_mem_arbiter #(
    .DATA_WIDTH (DATA_WIDTH)
    ) riscv_mem_arbiter (
      .i_width         (i_width),
      .i_data_sel      (i_alu_data[2:0]),
      .i_rs2_data      (i_rs2_data),
      .i_mem_rd_data   (i_mem_rd_data),
      .o_rs2_data      (riscv_mem_adapter__rs2_data),
      .o_mem_rd_data   (riscv_mem_adapter__mem_rd_data),
      .o_mem_wr_strb   (riscv_mem_adapter__mem_wr_strb)
    );
    
  riscv_mem_stage #(
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH)
    ) riscv_mem_stage (
      .clk             (clk),
      .nreset          (nreset),
      .enable          (enable),
      .i_stall         (i_stall),
      .i_flush         (i_flush),
      .i_rd_write      (i_rd_write),
      .i_read          (i_read),
      .i_write         (i_write),
      .i_wb_src        (i_wb_src),
      .i_valid_instr   (i_valid_instr),
      .i_mem_wr_ready  (i_mem_wr_ready),
      .i_mem_rd_valid  (i_mem_rd_valid),
      .i_desc_wready   (i_desc_wready),
      .i_resp_rready   (i_resp_rready),
      .i_alu_data      (i_alu_data),
      .i_rs2_data      (riscv_mem_adapter__rs2_data),
      .i_mem_rd_data   (riscv_mem_adapter__mem_rd_data),
      .i_resp_data     (i_resp_data),
      .i_mem_wr_strb   (riscv_mem_adapter__mem_wr_strb),
      .i_rd_addr       (i_rd_addr),
      .o_rd_write      (o_rd_write),
      .o_mem_rd_ready  (o_mem_rd_ready),
      .o_mem_wr_valid  (o_mem_wr_valid),
      .o_desc_wr       (o_desc_wr),
      .o_resp_rd       (o_resp_rd),
      .o_valid_instr   (o_valid_instr),
      .o_flush         (o_flush),
      .o_rd_write_data (o_rd_write_data),
      .o_mem_wr_data   (o_mem_wr_data),
      .o_desc_data     (o_desc_data),
      .o_mem_wr_strb   (o_mem_wr_strb),
      .o_mem_addr      (o_mem_addr),
      .o_rd_addr       (o_rd_addr)
    );
  
endmodule