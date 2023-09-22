import riscv_pkg::*;

module riscv_ex_jump_n_branches #(
  parameter DATA_WIDTH = 64
  )(
  input [1:0] i_branch_op,
  input i_pc_src,
  input i_jump,
  input i_branch,
  input i_carry,
  input i_zero,
  input i_call_mux_src,
  
  input [DATA_WIDTH - 1:0] i_pc,
  input [DATA_WIDTH - 1:0] i_wr_data,
  input [DATA_WIDTH - 1:0] i_rs1_data,
  input [DATA_WIDTH - 1:0] i_imm_data,
  
  output o_jump_branch,
  
  output [DATA_WIDTH - 1:0] o_pc
  );
  
  wire branch_valid_c;
  
  wire [DATA_WIDTH - 1:0] wr_rs1_data;
  
  assign wr_rs1_data = (i_call_mux_src) ? (i_wr_data) : (i_rs1_data);
  
  assign branch_valid_c = (i_branch_op == BRANCH_BEQ) ?
                          (!(i_zero ^ 1'h1)) ?          1'h1 :
                                                        1'h0 :
                          (i_branch_op == BRANCH_BNE) ?
                          (!(i_zero ^ 1'h0)) ?          1'h1 :
                                                        1'h0 :
                          (i_branch_op == BRANCH_BLT) ?
                          (i_carry) ?                   1'h1 :
                                                        1'h0 :
                          (i_branch_op == BRANCH_BGE) ?
                          (~i_carry || i_zero) ?        1'h1 :
                                                        1'h0 :
                          (1'h0);
  
  assign o_jump_branch = i_jump || (branch_valid_c && i_branch);
  assign o_pc = (i_pc_src) ? (i_rs1_data + i_imm_data) : (i_pc + i_imm_data);
  
endmodule
