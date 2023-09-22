import riscv_pkg::*;

module riscv_ras_ctrl_logic #(
  parameter ADDR_WIDTH = 64,
  parameter RAS_DEPTH = 16
  )(
  input i_ex_jump,
  
  input [4:0] i_ex_rs1_addr,
  input [4:0] i_ex_rd_addr,
  input [ADDR_WIDTH - 1:0] i_ras_addr,
  
  output o_push,
  output o_pop,
  output o_pop_then_push
  );
  
  wire ex_rd_link1_c;
  wire ex_rd_link5_c;
  wire ex_rs1_link1_c;
  wire ex_rs1_link5_c;
  wire ex_rd_rs1_c;
  wire ex_rd_link1_link5_c;
  wire ex_rs1_link1_link5_c;
  wire push_c;
  wire pop_c;
  wire pop_then_push_c;
  
  assign ex_rd_link1_c  = (i_ex_rd_addr  == LINK_1);
  assign ex_rd_link5_c  = (i_ex_rd_addr  == LINK_5);
  assign ex_rs1_link1_c = (i_ex_rs1_addr == LINK_1);
  assign ex_rs1_link5_c = (i_ex_rs1_addr == LINK_5);
  
  assign ex_rd_rs1_c = (i_ex_rd_addr == i_ex_rs1_addr);
  
  assign ex_rd_link1_link5_c  = ex_rd_link1_c  || ex_rd_link5_c;
  assign ex_rs1_link1_link5_c = ex_rs1_link1_c || ex_rs1_link5_c;
  
  assign push_c = ((ex_rd_link1_link5_c && (~ex_rs1_link1_link5_c)) ||
                  (ex_rd_link1_link5_c && ex_rs1_link1_link5_c && ex_rd_rs1_c)) && 
                  (i_ex_jump) && (i_ras_addr[$clog2(RAS_DEPTH) - 1: 0] < RAS_DEPTH);
  
  assign pop_c = ((~ex_rd_link1_link5_c) && ex_rs1_link1_link5_c) && (i_ex_jump) && (i_ras_addr[$clog2(RAS_DEPTH) - 1: 0] > 1);
  assign pop_then_push_c = (ex_rd_link1_link5_c && ex_rs1_link1_link5_c && (~ex_rd_rs1_c)) && (i_ex_jump) && (i_ras_addr[$clog2(RAS_DEPTH) - 1: 0] > 0);
  
  assign o_push = push_c;
  assign o_pop = pop_c;
  assign o_pop_then_push = pop_then_push_c;
  
  wire unused_ok = &{i_ras_addr[ADDR_WIDTH - 1: $clog2(RAS_DEPTH)]};
  
endmodule
