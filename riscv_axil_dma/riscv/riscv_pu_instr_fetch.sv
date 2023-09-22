import riscv_pkg::*;

module riscv_pu_instr_fetch #(
  parameter ADDR_WIDTH = 64,
  parameter DATA_WIDTH = 64
  )(
  input clk,
  input nreset,
  input enable,
  
  input i_stall,
  input i_flush, 
  input i_interr,
  
  input i_jump_branch,
  
  input [DATA_WIDTH - 1:0] i_pc,
  
  input [ADDR_WIDTH - 1:0] i_interr_addr,
  
  output o_read_instr,
  output o_flush,
  
  output [DATA_WIDTH - 1:0] o_pc
  );
  
  riscv_if_prog_counter #(
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH)
    ) riscv_if_prog_counter (
      .clk           (clk),
      .nreset        (nreset),
      .enable        (enable),
      .i_stall       (i_stall),
      .i_interr      (i_interr),
      .i_jump_branch (i_jump_branch),
      .i_pc          (i_pc),
      .i_interr_addr (i_interr_addr),
      .o_read_instr  (o_read_instr),
      .o_pc          (o_pc)
    );
  
  riscv_if_stage #(
    .DATA_WIDTH (DATA_WIDTH)
    ) riscv_if_stage (
      .clk           (clk),
      .nreset        (nreset),
      .enable        (enable),
      .i_stall       (i_stall),
      .i_flush       (i_flush),
      .o_flush       (o_flush)
    );
  
endmodule
