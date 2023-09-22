import riscv_pkg::*;

module riscv_ca_stacking_unit #(
  parameter ADDR_WIDTH = 64,
  parameter SU_FSM_WIDTH = 3
  )(
  input clk,
  input nreset,
  input enable,
  
  input i_abort,
  
  input i_data,
  
  output [SU_FSM_WIDTH - 1:0] o_fsm_status
  );
  
  wire riscv_su_ctrl_logic__start;
  wire riscv_su_ctrl_logic__all_in_stacked;
  wire riscv_su_ctrl_logic__interr_preemtion;
  wire riscv_su_ctrl_logic__ret_interr;
  wire riscv_su_ctrl_logic__all_unstacked;
  
  riscv_su_ctrl_logic #(
    .ADDR_WIDTH (ADDR_WIDTH)
    ) riscv_su_ctrl_logic (
      .i_data             (i_data),
      .o_start            (riscv_su_ctrl_logic__start),
      .o_all_in_stacked   (riscv_su_ctrl_logic__all_in_stacked),
      .o_interr_preemtion (riscv_su_ctrl_logic__interr_preemtion),
      .o_ret_interr       (riscv_su_ctrl_logic__ret_interr),
      .o_all_unstacked    (riscv_su_ctrl_logic__all_unstacked)
    );
    
  riscv_su_arbiter #(
    .ADDR_WIDTH   (ADDR_WIDTH),
    .SU_FSM_WIDTH (SU_FSM_WIDTH)
    ) riscv_su_arbiter (
      .clk                (clk),
      .nreset             (nreset),
      .enable             (enable),
      .i_abort            (i_abort),
      .i_start            (riscv_su_ctrl_logic__start),
      .i_all_in_stacked   (riscv_su_ctrl_logic__all_in_stacked),
      .i_interr_preemtion (riscv_su_ctrl_logic__interr_preemtion),
      .i_ret_interr       (riscv_su_ctrl_logic__ret_interr),
      .i_all_unstacked    (riscv_su_ctrl_logic__all_unstacked),
      .o_fsm_status       (o_fsm_status)
    );
    
endmodule
