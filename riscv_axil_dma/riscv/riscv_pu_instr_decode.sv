import riscv_pkg::*;

module riscv_pu_instr_decode #(
  parameter DATA_WIDTH = 64,
  parameter INSTR_WIDTH = 32
  )(
  input clk,
  input nreset,
  input enable,
  
  input i_stall,
  input i_flush_if,
  input i_flush_id,
  
  input [INSTR_WIDTH - 1:0] i_instr,
  input [DATA_WIDTH - 1:0] i_pc,
  
  output [2:0] o_alu_op,
  output [2:0] o_alu_src,
  output [2:0] o_imm,
  output [2:0] o_width,
  output [1:0] o_branch_op,
  output [1:0] o_csr_op,   
  output o_pc_src,
  output o_jump,
  output o_branch,
  output o_add_sub_srl_sra,
  output o_rd_write,
  output o_read,
  output o_write,
  output o_csr_write,
  output o_csr_read,
  output o_csr_rs1_imm,
  output o_wb_src,
  output o_valid_instr,
  output o_flush,
  
  output [DATA_WIDTH - 1:0] o_pc,
  output [DATA_WIDTH - 1:0] o_imm_data,
  output [4:0] o_rs1_addr,
  output [4:0] o_rs2_addr,
  output [4:0] o_rd_addr
  );
  
  wire [2:0]               riscv_id_control_unit__alu_op;
  wire [2:0]               riscv_id_control_unit__alu_src;
  wire [2:0]               riscv_id_control_unit__imm;
  wire [2:0]               riscv_id_control_unit__width;
  wire [1:0]               riscv_id_control_unit__branch_op;
  wire [1:0]               riscv_id_control_unit__csr_op;
  wire                     riscv_id_control_unit__pc_src;
  wire                     riscv_id_control_unit__jump;
  wire                     riscv_id_control_unit__branch;
  wire                     riscv_id_control_unit__add_sub_srl_sra;
  wire                     riscv_id_control_unit__rd_write;
  wire                     riscv_id_control_unit__read;
  wire                     riscv_id_control_unit__write;
  wire                     riscv_id_control_unit__csr_write;
  wire                     riscv_id_control_unit__csr_read;
  wire                     riscv_id_control_unit__csr_rs1_imm;
  wire                     riscv_id_control_unit__wb_src;
  wire                     riscv_id_control_unit__valid_instr;
  wire [DATA_WIDTH - 1:0]  riscv_id_imm_gen__imm_data;
    
  riscv_id_control_unit #(
    .INSTR_WIDTH (INSTR_WIDTH)
    ) riscv_id_control_unit (
      .i_instr           (i_instr),
      .o_alu_op          (riscv_id_control_unit__alu_op),
      .o_alu_src         (riscv_id_control_unit__alu_src),
      .o_imm             (riscv_id_control_unit__imm),
      .o_width           (riscv_id_control_unit__width),
      .o_branch_op       (riscv_id_control_unit__branch_op),
      .o_csr_op          (riscv_id_control_unit__csr_op),
      .o_pc_src          (riscv_id_control_unit__pc_src),
      .o_jump            (riscv_id_control_unit__jump),
      .o_branch          (riscv_id_control_unit__branch),
      .o_add_sub_srl_sra (riscv_id_control_unit__add_sub_srl_sra),
      .o_rd_write        (riscv_id_control_unit__rd_write),
      .o_read            (riscv_id_control_unit__read),
      .o_write           (riscv_id_control_unit__write),
      .o_csr_write       (riscv_id_control_unit__csr_write),
      .o_csr_read        (riscv_id_control_unit__csr_read),
      .o_csr_rs1_imm     (riscv_id_control_unit__csr_rs1_imm),
      .o_wb_src          (riscv_id_control_unit__wb_src),
      .o_valid_instr     (riscv_id_control_unit__valid_instr)
    );
    
  riscv_id_imm_gen #(
    .DATA_WIDTH  (DATA_WIDTH),
    .INSTR_WIDTH (INSTR_WIDTH)
    ) riscv_id_imm_gen (
      .i_imm             (riscv_id_control_unit__imm),
      .i_instr           (i_instr),
      .o_imm_data        (riscv_id_imm_gen__imm_data)
    );
    
  riscv_id_stage #(
    .DATA_WIDTH (DATA_WIDTH)
    ) riscv_id_stage (
      .clk               (clk),
      .nreset            (nreset),
      .enable            (enable),
      .i_stall           (i_stall),
      .i_flush_if        (i_flush_if),
      .i_flush_id        (i_flush_id),
      .i_alu_op          (riscv_id_control_unit__alu_op),
      .i_alu_src         (riscv_id_control_unit__alu_src),
      .i_imm             (riscv_id_control_unit__imm),
      .i_width           (riscv_id_control_unit__width),
      .i_branch_op       (riscv_id_control_unit__branch_op),
      .i_csr_op          (riscv_id_control_unit__csr_op),
      .i_pc_src          (riscv_id_control_unit__pc_src),
      .i_jump            (riscv_id_control_unit__jump),
      .i_branch          (riscv_id_control_unit__branch),
      .i_add_sub_srl_sra (riscv_id_control_unit__add_sub_srl_sra),
      .i_rd_write        (riscv_id_control_unit__rd_write),
      .i_read            (riscv_id_control_unit__read),
      .i_write           (riscv_id_control_unit__write),
      .i_csr_write       (riscv_id_control_unit__csr_write),
      .i_csr_read        (riscv_id_control_unit__csr_read),
      .i_csr_rs1_imm     (riscv_id_control_unit__csr_rs1_imm),
      .i_wb_src          (riscv_id_control_unit__wb_src),
      .i_valid_instr     (riscv_id_control_unit__valid_instr),
      .i_pc              (i_pc),
      .i_imm_data        (riscv_id_imm_gen__imm_data),
      .i_rs1_addr        (i_instr[19:15]),
      .i_rs2_addr        (i_instr[24:20]),
      .i_rd_addr         (i_instr[11:7]),
      .o_alu_op          (o_alu_op),
      .o_alu_src         (o_alu_src),
      .o_imm             (o_imm),
      .o_width           (o_width),
      .o_branch_op       (o_branch_op),
      .o_csr_op          (o_csr_op),   
      .o_pc_src          (o_pc_src),
      .o_jump            (o_jump),
      .o_branch          (o_branch),
      .o_add_sub_srl_sra (o_add_sub_srl_sra),
      .o_rd_write        (o_rd_write),
      .o_read            (o_read),
      .o_write           (o_write),
      .o_csr_write       (o_csr_write),
      .o_csr_read        (o_csr_read),
      .o_csr_rs1_imm     (o_csr_rs1_imm),
      .o_wb_src          (o_wb_src),
      .o_valid_instr     (o_valid_instr),
      .o_flush           (o_flush),
      .o_pc              (o_pc),
      .o_imm_data        (o_imm_data),
      .o_rs1_addr        (o_rs1_addr),
      .o_rs2_addr        (o_rs2_addr),
      .o_rd_addr         (o_rd_addr)
    );
    
endmodule
