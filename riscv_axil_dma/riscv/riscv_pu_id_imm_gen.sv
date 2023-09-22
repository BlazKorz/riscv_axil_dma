import riscv_pkg::*;

module riscv_id_imm_gen #(
  parameter DATA_WIDTH = 64,
  parameter INSTR_WIDTH = 32
  )(
  input [2:0] i_imm,
  
  input [INSTR_WIDTH - 1:0] i_instr,
  
  output [DATA_WIDTH - 1:0] o_imm_data
  );
      
  wire [DATA_WIDTH - 1:0] imm_i_c;
  wire [DATA_WIDTH - 1:0] imm_s_c;
  wire [DATA_WIDTH - 1:0] imm_u_c;
  wire [DATA_WIDTH - 1:0] imm_j_c;
  wire [DATA_WIDTH - 1:0] imm_b_c;
  wire signbit_c;
  
  assign signbit_c = i_instr[31];
  assign imm_i_c = {{32{signbit_c}}, {20{signbit_c}},  i_instr[31:20]};
  assign imm_s_c = {{32{signbit_c}}, {20{signbit_c}},  i_instr[31:25], i_instr[11:7]};
  assign imm_u_c = {{32{signbit_c}}, i_instr[31:12], 12'h0};
  assign imm_j_c = {{32{signbit_c}}, {12{signbit_c}},  i_instr[19:12], i_instr[20],    i_instr[30:21], 1'h0};
  assign imm_b_c = {{32{signbit_c}}, {20{signbit_c}},  i_instr[7],     i_instr[30:25], i_instr[11:8],  1'h0};
  
  assign o_imm_data = (i_imm == IMM_I_TYPE) ? (imm_i_c) :
                      (i_imm == IMM_S_TYPE) ? (imm_s_c) :
                      (i_imm == IMM_U_TYPE) ? (imm_u_c) :
                      (i_imm == IMM_J_TYPE) ? (imm_j_c) :
                      (i_imm == IMM_B_TYPE) ? (imm_b_c) :
                                              ({DATA_WIDTH{1'h0}});
  
endmodule
