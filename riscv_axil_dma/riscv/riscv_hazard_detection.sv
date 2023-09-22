import riscv_pkg::*;
import common_cells_pkg::*;

module riscv_mu_hazard_detection_unit #(

  )(
  input clk,
  input nreset,
  input enable,
  
  input i_mem_wr_ready,
  input i_mem_wr_valid,
  input i_mem_rd_valid,
  input i_mem_rd_ready,
  input i_jump_branch,
  
  output o_stall_if,
  output o_stall_id,
  output o_stall_rd_reg,
  output o_stall_wr_reg,
  output o_stall_ex,
  output o_stall_mem,
  output o_flush_if,
  output o_flush_id,
  output o_flush_ex
  );
  
  wire rready_c;
  reg  rready_r;
  
  wire wvalid_c;
  reg  wvalid_r;
  
  assign rready_c = (rready_r) ?
                    (i_mem_rd_valid) ? 1'h0 :
                                       rready_r:
                    (i_mem_rd_ready) ? 1'h1 :
                                       1'h0;
 `RTL_REG_ASYNC (clk, nreset, enable, rready_c, rready_r, 1);
  
  
  assign wvalid_c = (wvalid_r) ?
                    (i_mem_wr_ready) ? 1'h0 :
                                       wvalid_r:
                    (i_mem_wr_valid) ? 1'h1 :
                                       1'h0;
 `RTL_REG_ASYNC (clk, nreset, enable, wvalid_c, wvalid_r, 1);
  
  assign o_stall_if = rready_c || wvalid_c;
  assign o_stall_id = rready_c || wvalid_c;
  assign o_stall_rd_reg = rready_c || wvalid_c;
  assign o_stall_wr_reg = rready_c || wvalid_c;
  assign o_stall_ex = rready_c || wvalid_c;
  assign o_stall_mem = rready_c || wvalid_c;
  
  assign o_flush_if = i_jump_branch;
  assign o_flush_id = i_jump_branch;
  assign o_flush_ex = i_jump_branch;
  
endmodule
