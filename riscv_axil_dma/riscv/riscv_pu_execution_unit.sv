import riscv_pkg::*;

module riscv_pu_execution_unit #(
  parameter ADDR_WIDTH = 64,
  parameter DATA_WIDTH = 64
  )(
  input clk,
  input nreset,
  input enable,
  
  input i_stall,
  input i_flush_id,
  input i_flush_ex,
  
  input [2:0] i_alu_op,
  input [2:0] i_alu_src,
  input [2:0] i_imm,
  input [2:0] i_width,
  input [1:0] i_branch_op,
  input i_pc_src,
  input i_jump,
  input i_branch,
  input i_add_sub_srl_sra,
  input i_rd_write,
  input i_read,
  input i_write,
  input i_wb_src,
  input i_valid_instr,
  input i_ex_rd_write,
  input i_mem_rd_write,
  
  input [DATA_WIDTH - 1:0] i_pc,
  input [DATA_WIDTH - 1:0] i_alu_data,
  input [DATA_WIDTH - 1:0] i_wr_data,
  input [DATA_WIDTH - 1:0] i_rs1_data,
  input [DATA_WIDTH - 1:0] i_rs2_data,
  input [DATA_WIDTH - 1:0] i_imm_data,

  input [4:0] i_rs1_addr,
  input [4:0] i_rs2_addr,
  input [4:0] i_rd_addr,
  input [4:0] i_ex_rd_addr,
  input [4:0] i_mem_rd_addr,
  
  output [2:0] o_width,
  output o_jump,
  output o_rd_write,
  output o_read,
  output o_write,
  output o_wb_src,
  output o_valid_instr,
  output o_jump_branch,
  output o_flush,
  
  output [DATA_WIDTH - 1:0] o_pc,
  output [DATA_WIDTH - 1:0] o_alu_data,
  output [DATA_WIDTH - 1:0] o_rs2_data,
  
  output [4:0] o_rs1_addr,
  output [4:0] o_rd_addr
  );
  
  wire [1:0]              riscv_ex_forwarding_unit__mux1_src;
  wire [1:0]              riscv_ex_forwarding_unit__mux2_src;
  wire [1:0]              riscv_ex_forwarding_unit__mux3_src;
  wire                    riscv_ex_forwarding_unit__ras_mux_src;
  wire                    riscv_ex_forwarding_unit__call_mux_src;
  wire                    riscv_ex_arithmetic_logic_unit__carry;
  wire                    riscv_ex_arithmetic_logic_unit__zero;
  wire [DATA_WIDTH - 1:0] riscv_ex_arithmetic_logic_unit__alu_data;
  wire [DATA_WIDTH - 1:0] riscv_ex_arithmetic_logic_unit__rs1_data;
  wire [DATA_WIDTH - 1:0] riscv_ex_arithmetic_logic_unit__rs2_data;
  wire                    riscv_ex_jump_n_branches__jump_branch;
  wire [DATA_WIDTH - 1:0] riscv_ex_jump_n_branches__pc;
  
  riscv_ex_forwarding_unit #(
    .DATA_WIDTH (DATA_WIDTH)
    ) riscv_ex_forwarding_unit (
      .i_imm             (i_imm),
      .i_jump            (i_jump),
      .i_ex_rd_write     (i_ex_rd_write),
      .i_mem_rd_write    (i_mem_rd_write),
      .i_rs1_addr        (i_rs1_addr),
      .i_rs2_addr        (i_rs2_addr),
      .i_id_rd_addr      (i_rd_addr),
      .i_ex_rd_addr      (i_ex_rd_addr),
      .i_mem_rd_addr     (i_mem_rd_addr),
      .o_mux1_src        (riscv_ex_forwarding_unit__mux1_src), 
      .o_mux2_src        (riscv_ex_forwarding_unit__mux2_src),
      .o_mux3_src        (riscv_ex_forwarding_unit__mux3_src),
      .o_ras_mux_src     (riscv_ex_forwarding_unit__ras_mux_src),
      .o_call_mux_src    (riscv_ex_forwarding_unit__call_mux_src)
    );
  
  riscv_ex_arithmetic_logic_unit #(
    .DATA_WIDTH (DATA_WIDTH)
    ) riscv_ex_arithmetic_logic_unit (
      .i_alu_op          (i_alu_op),
      .i_alu_src         (i_alu_src),
      .i_width           (i_width),
      .i_mux1_src        (riscv_ex_forwarding_unit__mux1_src), 
      .i_mux2_src        (riscv_ex_forwarding_unit__mux2_src),
      .i_mux3_src        (riscv_ex_forwarding_unit__mux3_src),
      .i_add_sub_srl_sra (i_add_sub_srl_sra),
      .i_read            (i_read),
      .i_write           (i_write),
      .i_pc              (i_pc),
      .i_alu_data        (i_alu_data),
      .i_wr_data         (i_wr_data),
      .i_rs1_data        (i_rs1_data),
      .i_rs2_data        (i_rs2_data),
      .i_imm_data        (i_imm_data),
      .o_carry           (riscv_ex_arithmetic_logic_unit__carry),
      .o_zero            (riscv_ex_arithmetic_logic_unit__zero),
      .o_alu_data        (riscv_ex_arithmetic_logic_unit__alu_data),
      .o_rs1_data        (riscv_ex_arithmetic_logic_unit__rs1_data),
      .o_rs2_data        (riscv_ex_arithmetic_logic_unit__rs2_data)
    );
    
  riscv_ex_jump_n_branches #(
    .DATA_WIDTH (DATA_WIDTH)
    ) riscv_ex_jump_n_branches (
      .i_branch_op       (i_branch_op),
      .i_pc_src          (i_pc_src),
      .i_jump            (i_jump),
      .i_branch          (i_branch),
      .i_carry           (riscv_ex_arithmetic_logic_unit__carry),
      .i_zero            (riscv_ex_arithmetic_logic_unit__zero),
      .i_call_mux_src    (1'b0),
      .i_pc              (i_pc),
      .i_wr_data         (i_wr_data),
      .i_rs1_data        (i_rs1_data),
      .i_imm_data        (i_imm_data),
      .o_jump_branch     (riscv_ex_jump_n_branches__jump_branch),
      .o_pc              (riscv_ex_jump_n_branches__pc)
    );
    
  riscv_ex_stage #(
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH)
    ) riscv_ex_stage (
      .clk               (clk),
      .nreset            (nreset),
      .enable            (enable),
      .i_stall           (i_stall),
      .i_flush_id        (i_flush_id),
      .i_flush_ex        (i_flush_ex),
      .i_width           (i_width),
      .i_jump            (i_jump),
      .i_rd_write        (i_rd_write),
      .i_read            (i_read),
      .i_write           (i_write),
      .i_wb_src          (i_wb_src),
      .i_valid_instr     (i_valid_instr),
      .i_jump_branch     (riscv_ex_jump_n_branches__jump_branch),
      .i_pc              (riscv_ex_jump_n_branches__pc),
      .i_alu_data        (riscv_ex_arithmetic_logic_unit__alu_data),
      .i_rs2_data        (riscv_ex_arithmetic_logic_unit__rs2_data),
      .i_rs1_addr        (i_rs1_addr),
      .i_rd_addr         (i_rd_addr),
      .o_width           (o_width),
      .o_jump            (o_jump),
      .o_rd_write        (o_rd_write),
      .o_read            (o_read),
      .o_write           (o_write),
      .o_wb_src          (o_wb_src),
      .o_valid_instr     (o_valid_instr),
      .o_jump_branch     (o_jump_branch),
      .o_flush           (o_flush),
      .o_pc              (o_pc),
      .o_alu_data        (o_alu_data),
      .o_rs2_data        (o_rs2_data),
      .o_rs1_addr        (o_rs1_addr),
      .o_rd_addr         (o_rd_addr)
    );
  
endmodule
