import riscv_pkg::*;

module riscv_ca_return_addr_stack #(
  parameter ADDR_WIDTH = 64,
  parameter RAS_DEPTH = 16,
  parameter RAS_FSM_WIDTH = 3
  )(
  input clk,
  input nreset,
  input enable,
  
  input i_ex_stall,
  
  input i_abort,
  input i_ex_jump,
  
  input [4:0] i_ex_rs1_addr,
  input [4:0] i_ex_rd_addr,
  input [ADDR_WIDTH - 1:0] i_wr_addr,
  
  output o_write,
  output o_read,
  
  output [RAS_FSM_WIDTH - 1:0] o_fsm_status,
  
  output [ADDR_WIDTH - 1:0] o_wr_addr,
  output [ADDR_WIDTH - 1:0] o_rd_addr
  );
  
  wire riscv_ras_logic__push;
  wire riscv_ras_logic__pop;
  wire riscv_ras_logic__pop_then_push;
  wire riscv_ras_arbiter__push;
  wire riscv_ras_arbiter__pop;
  
  riscv_ras_ctrl_logic #(
    .ADDR_WIDTH (ADDR_WIDTH),
    .RAS_DEPTH  (RAS_DEPTH)
    ) riscv_ras_ctrl_logic (
      .i_ex_jump       (i_ex_jump),
      .i_ex_rs1_addr   (i_ex_rs1_addr),
      .i_ex_rd_addr    (i_ex_rd_addr),
      .i_ras_addr      (i_wr_addr),
      .o_push          (riscv_ras_logic__push),
      .o_pop           (riscv_ras_logic__pop),
      .o_pop_then_push (riscv_ras_logic__pop_then_push)
    );
    
  riscv_ras_arbiter #(
    .ADDR_WIDTH    (ADDR_WIDTH),
    .RAS_DEPTH     (RAS_DEPTH),
    .RAS_FSM_WIDTH (RAS_FSM_WIDTH)
    ) riscv_ras_arbiter (
      .clk             (clk),
      .nreset          (nreset),
      .enable          (enable),
      .i_abort         (i_abort),
      .i_push          (riscv_ras_logic__push),
      .i_pop           (riscv_ras_logic__pop),
      .i_pop_then_push (riscv_ras_logic__pop_then_push),
      .o_push          (o_write),
      .o_pop           (o_read),      
      .o_fsm_status    (o_fsm_status),
      .o_push_addr     (o_wr_addr),
      .o_pop_addr      (o_rd_addr)
    );
  
endmodule
