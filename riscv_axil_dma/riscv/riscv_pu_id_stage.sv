import riscv_pkg::*;

module riscv_id_stage #(
  parameter DATA_WIDTH = 64
  )(
  input clk,
  input nreset,
  input enable,
  
  input i_stall,
  input i_flush_if,
  input i_flush_id,
  
  input [2:0] i_alu_op,
  input [2:0] i_alu_src,
  input [2:0] i_imm,
  input [2:0] i_width,
  input [1:0] i_branch_op,
  input [1:0] i_csr_op,   
  input i_pc_src,
  input i_jump,
  input i_branch,
  input i_add_sub_srl_sra,
  input i_rd_write,
  input i_read,
  input i_write,
  input i_csr_write,
  input i_csr_read,
  input i_csr_rs1_imm,
  input i_wb_src,
  input i_valid_instr,
  
  input [DATA_WIDTH - 1:0] i_pc,
  input [DATA_WIDTH - 1:0] i_imm_data,
  input [4:0] i_rs1_addr,
  input [4:0] i_rs2_addr,
  input [4:0] i_rd_addr,
  
  output reg [2:0] o_alu_op,
  output reg [2:0] o_alu_src,
  output reg [2:0] o_imm,
  output reg [2:0] o_width,
  output reg [1:0] o_branch_op,
  output reg [1:0] o_csr_op,   
  output reg o_pc_src,
  output reg o_jump,
  output reg o_branch,
  output reg o_add_sub_srl_sra,
  output reg o_rd_write,
  output reg o_read,
  output reg o_write,
  output reg o_csr_write,
  output reg o_csr_read,
  output reg o_csr_rs1_imm,
  output reg o_wb_src,
  output reg o_valid_instr,
  output reg o_flush,
  
  output reg [DATA_WIDTH - 1:0] o_pc,
  output reg [DATA_WIDTH - 1:0] o_imm_data,
  output reg [4:0] o_rs1_addr,
  output reg [4:0] o_rs2_addr,
  output reg [4:0] o_rd_addr
  );
  
  wire id_stage_en_c;
  
  wire flush_c;
  
  wire [2:0] alu_op_c;
  wire [2:0] alu_src_c;
  wire [2:0] imm_c;
  wire [2:0] width_c;
  wire [1:0] branch_op_c;
  wire [1:0] csr_op_c;
  wire pc_src_c;
  wire jump_c;
  wire branch_c;
  wire add_sub_srl_sra_c;
  wire rd_write_c;
  wire read_c;
  wire write_c;
  wire csr_write_c;
  wire csr_read_c;
  wire csr_rs1_imm_c;
  wire wb_src_c;
  wire valid_instr_c;
  
  assign flush_c = i_flush_if || i_flush_id;
  
  assign id_stage_en_c = (!i_stall) && enable;
  assign alu_op_c          = (flush_c) ? (3'h0) : (i_alu_op);
  assign alu_src_c         = (flush_c) ? (3'h0) : (i_alu_src);
  assign imm_c             = (flush_c) ? (3'h0) : (i_imm);
  assign width_c           = (flush_c) ? (3'h0) : (i_width);
  assign branch_op_c       = (flush_c) ? (2'h0) : (i_branch_op);
  assign csr_op_c          = (flush_c) ? (2'h0) : (i_csr_op);
  assign pc_src_c          = (flush_c) ? (1'h0) : (i_pc_src);
  assign jump_c            = (flush_c) ? (1'h0) : (i_jump);
  assign branch_c          = (flush_c) ? (1'h0) : (i_branch);
  assign add_sub_srl_sra_c = (flush_c) ? (1'h0) : (i_add_sub_srl_sra);
  assign rd_write_c        = (flush_c) ? (1'h0) : (i_rd_write);
  assign read_c            = (flush_c) ? (1'h0) : (i_read);
  assign write_c           = (flush_c) ? (1'h0) : (i_write);
  assign csr_write_c       = (flush_c) ? (1'h0) : (i_csr_write);
  assign csr_read_c        = (flush_c) ? (1'h0) : (i_csr_read);
  assign csr_rs1_imm_c     = (flush_c) ? (1'h0) : (i_csr_rs1_imm);
  assign wb_src_c          = (flush_c) ? (1'h0) : (i_wb_src);
  assign valid_instr_c     = (flush_c) ? (1'h0) : (i_valid_instr);
  always_ff @(posedge clk or negedge nreset) begin
    if (!nreset) begin
      o_alu_op          <= 3'h0;
      o_alu_src         <= 3'h0;
      o_imm             <= 3'h0;
      o_width           <= 3'h0;
      o_branch_op       <= 2'h0;
      o_csr_op          <= 2'h0;
      o_pc_src          <= 1'h0;
      o_jump            <= 1'h0;
      o_branch          <= 1'h0;
      o_add_sub_srl_sra <= 1'h0;
      o_rd_write        <= 1'h0;
      o_read            <= 1'h0;
      o_write           <= 1'h0;
      o_csr_write       <= 1'h0;
      o_csr_read        <= 1'h0;
      o_csr_rs1_imm     <= 1'h0;
      o_wb_src          <= 1'h0;
      o_valid_instr     <= 1'h0;
      o_flush           <= 1'h0;
      o_pc              <= {DATA_WIDTH{1'h0}};
      o_imm_data        <= {DATA_WIDTH{1'h0}};
      o_rs1_addr        <= 5'h0;
      o_rs2_addr        <= 5'h0;
      o_rd_addr         <= 5'h0;
    end else if (id_stage_en_c) begin
      o_alu_op          <= alu_op_c;
      o_alu_src         <= alu_src_c;
      o_imm             <= imm_c;
      o_width           <= width_c;
      o_branch_op       <= branch_op_c;
      o_csr_op          <= csr_op_c;
      o_pc_src          <= pc_src_c;
      o_jump            <= jump_c;
      o_branch          <= branch_c;
      o_add_sub_srl_sra <= add_sub_srl_sra_c;
      o_rd_write        <= rd_write_c;
      o_read            <= read_c;
      o_write           <= write_c;
      o_csr_write       <= csr_write_c;
      o_csr_read        <= csr_read_c;
      o_csr_rs1_imm     <= csr_rs1_imm_c;
      o_wb_src          <= wb_src_c;
      o_valid_instr     <= valid_instr_c;
      o_flush           <= flush_c;
      o_pc              <= i_pc;
      o_imm_data        <= i_imm_data;
      o_rs1_addr        <= i_rs1_addr;
      o_rs2_addr        <= i_rs2_addr;
      o_rd_addr         <= i_rd_addr;
    end
  end
  
endmodule
