import riscv_pkg::*;

module riscv_su_ctrl_logic #(
  parameter ADDR_WIDTH = 64
  )(
  input i_data,
  
  output o_start,
  output o_all_in_stacked,
  output o_interr_preemtion,
  output o_ret_interr,
  output o_all_unstacked
  );
  
endmodule
