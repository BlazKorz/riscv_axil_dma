import riscv_pkg::*;

module riscv_ex_forwarding_unit #(
  parameter DATA_WIDTH = 64
  )(
  input [2:0] i_imm,
  input i_jump,
  input i_ex_rd_write,
  input i_mem_rd_write,
  
  input [4:0] i_rs1_addr,
  input [4:0] i_rs2_addr,
  input [4:0] i_id_rd_addr,
  input [4:0] i_ex_rd_addr,
  input [4:0] i_mem_rd_addr,
  
  output [1:0] o_mux1_src,
  output [1:0] o_mux2_src,
  output [1:0] o_mux3_src,
  output o_ras_mux_src,
  output o_call_mux_src
  );
  
  wire [1:0] mux1_src_c;
  wire [1:0] mux2_src_c;
  wire [1:0] mux3_src_c;
  wire ras_mux_src_c;
  wire call_mux_src_c;
  
  assign mux1_src_c = (i_jump) ?                                                                 (2'b00) :
                      (i_ex_rd_write & (i_ex_rd_addr != 0) & (i_ex_rd_addr == i_rs1_addr)) ?     (2'b01) :
                      (i_mem_rd_write && (i_mem_rd_addr != 0) && 
                      ~(i_ex_rd_write && (i_ex_rd_addr != 0) && (i_ex_rd_addr == i_rs1_addr)) && 
                      (i_mem_rd_addr == i_rs1_addr)) ?                                           (2'b10) :
                                                                                                 (2'b00);
  
  assign mux2_src_c = (i_jump || (i_imm == IMM_S_TYPE)) ?                                        (2'b00) :
                      (i_ex_rd_write && (i_ex_rd_addr != 0) && (i_ex_rd_addr == i_rs2_addr)) ?   (2'b01) :
                      (i_mem_rd_write && (i_mem_rd_addr != 0) && 
                      ~(i_ex_rd_write && (i_ex_rd_addr != 0) && (i_ex_rd_addr == i_rs2_addr)) && 
                      (i_mem_rd_addr == i_rs2_addr)) ?                                           (2'b10) :
                                                                                                 (2'b00);
  
  assign mux3_src_c = ((i_imm == IMM_S_TYPE) && 
                      (i_ex_rd_write && (i_ex_rd_addr != 0) && (i_ex_rd_addr == i_rs2_addr))) ?  (2'b01) :
                      ((i_imm == IMM_S_TYPE) && (i_mem_rd_write && (i_mem_rd_addr != 0) && 
                      ~(i_ex_rd_write && (i_ex_rd_addr != 0) && (i_ex_rd_addr == i_rs2_addr)) && 
                      (i_mem_rd_addr == i_rs2_addr))) ?                                          (2'b10) :
                                                                                                 (2'b00);
  
  assign ras_mux_src_c = (i_jump && ((i_mem_rd_addr == i_id_rd_addr) && (i_mem_rd_addr != 0))) ? (1'b1) :
                                                                                                 (1'b0);
  
  assign call_mux_src_c = (i_jump && ((i_mem_rd_addr == i_rs1_addr) && (i_mem_rd_addr != 0))) ? (1'b1) :
                                                                                                (1'b0);
  
  assign o_mux1_src = ((i_imm == IMM_U_TYPE) || (i_imm == IMM_J_TYPE)) ? (2'b00) :
                                                                         (mux1_src_c);
  
  assign o_mux2_src = ((i_imm == IMM_I_TYPE) || (i_imm == IMM_U_TYPE) || (i_imm == IMM_J_TYPE)) ? (2'b00) :
                                                                                                  (mux2_src_c);
  
  assign o_mux3_src = mux3_src_c;
  assign o_ras_mux_src = ras_mux_src_c;
  assign o_call_mux_src = call_mux_src_c;
  
endmodule
