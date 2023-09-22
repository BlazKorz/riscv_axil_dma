import riscv_pkg::*;

module riscv_ex_stage #(
  parameter ADDR_WIDTH = 64,
  parameter DATA_WIDTH = 64
  )(
  input clk,
  input nreset,
  input enable,
  
  input i_stall,
  input i_flush_id,
  input i_flush_ex,
  
  input [2:0] i_width,
  input i_jump,
  input i_rd_write,
  input i_read,
  input i_write,
  input i_wb_src,
  input i_valid_instr,
  input i_jump_branch,
  
  input [DATA_WIDTH - 1:0] i_pc,
  input [DATA_WIDTH - 1:0] i_alu_data,
  input [DATA_WIDTH - 1:0] i_rs2_data,
  
  input [4:0] i_rs1_addr,
  input [4:0] i_rd_addr,
  
  output reg [2:0] o_width,
  output reg o_jump,
  output reg o_rd_write,
  output reg o_read,
  output reg o_write,
  output reg o_wb_src,
  output reg o_valid_instr,
  output reg o_jump_branch,
  output reg o_flush,
  
  output reg [DATA_WIDTH - 1:0] o_pc,
  output reg [DATA_WIDTH - 1:0] o_alu_data,
  output reg [DATA_WIDTH - 1:0] o_rs2_data,
  
  output reg [4:0] o_rs1_addr,
  output reg [4:0] o_rd_addr
  );
  
  wire ex_stage_en_c;
  
  wire flush_c;
  
  wire [2:0] width_c;
  wire rd_write_c;   
  wire read_c;      
  wire write_c;    
  wire wb_src_c;   
  wire valid_instr_c;
  wire jump_branch_c;
  
  wire [DATA_WIDTH - 1:0] alu_data_c;
  
  wire [4:0] rd_addr_c;
  
  assign flush_c = i_flush_id || i_flush_ex;
  
  assign ex_stage_en_c = (!i_stall) && enable;
  assign width_c       = (flush_c) ? ('h0) : (i_width);
  assign jump_c        = (flush_c) ? ('h0) : (i_jump);
  assign rd_write_c    = (flush_c) ? ('h0) : (i_rd_write);
  assign read_c        = (flush_c) ? ('h0) : (i_read);
  assign write_c       = (flush_c) ? ('h0) : (i_write);
  assign wb_src_c      = (flush_c) ? ('h0) : (i_wb_src);
  assign valid_instr_c = (flush_c) ? ('h0) : (i_valid_instr);
  assign jump_branch_c = (flush_c) ? ('h0) : (i_jump_branch);
  always @(posedge clk or negedge nreset) begin
    if (!nreset) begin
      o_width       <= 3'h0;
      o_jump        <= 1'h0;
      o_rd_write    <= 1'h0;
      o_read        <= 1'h0;
      o_write       <= 1'h0;
      o_wb_src      <= 1'h0;
      o_valid_instr <= 1'h0;
      o_jump_branch <= 1'h0;
      o_flush       <= 1'h0;
      o_pc          <= {DATA_WIDTH{1'h0}};
      o_alu_data    <= {DATA_WIDTH{1'h0}};
      o_rs2_data    <= {DATA_WIDTH{1'h0}};
      o_rs1_addr    <= 5'h0;
      o_rd_addr     <= 5'h0;
    end else if (ex_stage_en_c) begin
      o_width       <= width_c;
      o_jump        <= jump_c;
      o_rd_write    <= rd_write_c;
      o_read        <= read_c;
      o_write       <= write_c;
      o_wb_src      <= wb_src_c;
      o_valid_instr <= valid_instr_c;
      o_jump_branch <= jump_branch_c;
      o_flush       <= flush_c;
      o_pc          <= i_pc;
      o_alu_data    <= i_alu_data;
      o_rs2_data    <= i_rs2_data;
      o_rs1_addr    <= i_rs1_addr;
      o_rd_addr     <= i_rd_addr;
    end
  end
  
endmodule
