import riscv_pkg::*;

module riscv_mu_processing_unit #(
  parameter ADDR_WIDTH = 64,
  parameter DATA_WIDTH = 64,
  parameter INSTR_WIDTH = 32,
  parameter STRB_WIDTH = DATA_WIDTH / 8
  )(
  input clk,
  input nreset,
  input enable,
  
  input i_stall_if,
  input i_stall_id,
  input i_stall_rd_reg,
  input i_stall_wr_reg,
  input i_stall_ex,
  input i_stall_mem,
  
  input i_flush_if,
  input i_flush_id,
  input i_flush_ex,
  input i_interr,
  
  input i_mem_wr_ready,
  input i_mem_rd_valid,
  input i_desc_wready,
  input i_resp_rready,
  
  input i_ras_read,
  
  input [INSTR_WIDTH - 1:0] i_instr,
  input [DATA_WIDTH - 1:0] i_pc,
  
  input [DATA_WIDTH - 1:0] i_mem_rd_data,
  input [9:0] i_resp_data,
  input [DATA_WIDTH - 1:0] i_ras_data,
  
  input [ADDR_WIDTH - 1:0] i_interr_addr,
  
  output [1:0] o_csr_op,
  output o_ex_jump,
  output o_mem_rd_ready,
  output o_mem_wr_valid,
  output o_desc_wr,
  output o_resp_rd,
  output o_csr_write,
  output o_csr_read,
  output o_csr_rs1_imm,
  output o_read_instr,
  output o_jump_branch,
  output o_flush_if,
  
  output [DATA_WIDTH - 1:0] o_if_pc,
  output [DATA_WIDTH - 1:0] o_ex_pc,
  output [DATA_WIDTH - 1:0] o_mem_wr_data,
  output [60:0]             o_desc_data,
  output [STRB_WIDTH - 1:0] o_mem_wr_strb,
  
  output [ADDR_WIDTH - 1:0] o_mem_addr,

  output [4:0] o_ex_rs1_addr,
  output [4:0] o_ex_rd_addr
  );
  
  wire                    riscv_pu_instr_fetch__flush;
  wire [DATA_WIDTH - 1:0] riscv_pu_instr_fetch__pc;
  wire [2:0]              riscv_pu_instr_decode__alu_op;
  wire [2:0]              riscv_pu_instr_decode__alu_src;
  wire [2:0]              riscv_pu_instr_decode__imm;
  wire [2:0]              riscv_pu_instr_decode__width;
  wire [1:0]              riscv_pu_instr_decode__branch_op;
  wire                    riscv_pu_instr_decode__pc_src;
  wire                    riscv_pu_instr_decode__jump;
  wire                    riscv_pu_instr_decode__branch;
  wire                    riscv_pu_instr_decode__add_sub_srl_sra;
  wire                    riscv_pu_instr_decode__rd_write;
  wire                    riscv_pu_instr_decode__read;
  wire                    riscv_pu_instr_decode__write;
  wire                    riscv_pu_instr_decode__wb_src;
  wire                    riscv_pu_instr_decode__valid_instr;
  wire                    riscv_pu_instr_decode__flush;
  wire [DATA_WIDTH - 1:0] riscv_pu_instr_decode__pc;
  wire [DATA_WIDTH - 1:0] riscv_pu_instr_decode__imm_data;
  wire [4:0]              riscv_pu_instr_decode__rs1_addr;
  wire [4:0]              riscv_pu_instr_decode__rs2_addr;
  wire [4:0]              riscv_pu_instr_decode__rd_addr;
  wire [DATA_WIDTH - 1:0] riscv_pu_register__rs1_data;
  wire [DATA_WIDTH - 1:0] riscv_pu_register__rs2_data;
  wire [2:0]              riscv_pu_execution_unit__width;
  wire                    riscv_pu_execution_unit__jump;
  wire                    riscv_pu_execution_unit__rd_write;
  wire                    riscv_pu_execution_unit__read;
  wire                    riscv_pu_execution_unit__write;
  wire                    riscv_pu_execution_unit__wb_src;
  wire                    riscv_pu_execution_unit__valid_instr;
  wire                    riscv_pu_execution_unit__jump_branch;
  wire                    riscv_pu_execution_unit__flush;
  wire [DATA_WIDTH - 1:0] riscv_pu_execution_unit__pc;
  wire [DATA_WIDTH - 1:0] riscv_pu_execution_unit__alu_data;
  wire [DATA_WIDTH - 1:0] riscv_pu_execution_unit__rs2_data;
  wire [4:0]              riscv_pu_execution_unit__rs1_addr;
  wire [4:0]              riscv_pu_execution_unit__rd_addr;
  wire                    riscv_pu_memory_adapter__rd_write;
  wire                    riscv_pu_memory_adapter__valid_instr;
  wire                    riscv_pu_memory_adapter__flush;
  wire [DATA_WIDTH - 1:0] riscv_pu_memory_adapter__rd_write_data;
  wire [4:0]              riscv_pu_memory_adapter__rd_addr;
  
  riscv_pu_instr_fetch #(
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH)
    ) riscv_pu_instr_fetch (
      .clk                (clk),
      .nreset             (nreset),
      .enable             (enable),
      .i_stall            (i_stall_if),
      .i_flush            (i_flush_if),
      .i_interr           (i_interr),
      .i_jump_branch      (riscv_pu_execution_unit__jump_branch),
      .i_pc               (riscv_pu_execution_unit__pc),
      .i_interr_addr      (i_interr_addr),
      .o_read_instr       (o_read_instr),
      .o_flush            (riscv_pu_instr_fetch__flush),
      .o_pc               (o_if_pc)
    );
  
  riscv_pu_instr_decode #(
    .DATA_WIDTH  (DATA_WIDTH),
    .INSTR_WIDTH (INSTR_WIDTH)
    ) riscv_pu_instr_decode (
      .clk                (clk),
      .nreset             (nreset),
      .enable             (enable),
      .i_stall            (i_stall_id),
      .i_flush_if         (riscv_pu_instr_fetch__flush),
      .i_flush_id         (i_flush_id),
      .i_instr            (i_instr),
      .i_pc               (i_pc),
      .o_alu_op           (riscv_pu_instr_decode__alu_op),
      .o_alu_src          (riscv_pu_instr_decode__alu_src),
      .o_imm              (riscv_pu_instr_decode__imm),
      .o_width            (riscv_pu_instr_decode__width),
      .o_branch_op        (riscv_pu_instr_decode__branch_op),
      .o_csr_op           (o_csr_op),
      .o_pc_src           (riscv_pu_instr_decode__pc_src),
      .o_jump             (riscv_pu_instr_decode__jump),
      .o_branch           (riscv_pu_instr_decode__branch),
      .o_add_sub_srl_sra  (riscv_pu_instr_decode__add_sub_srl_sra),
      .o_rd_write         (riscv_pu_instr_decode__rd_write),
      .o_read             (riscv_pu_instr_decode__read),
      .o_write            (riscv_pu_instr_decode__write),
      .o_csr_write        (o_csr_write),
      .o_csr_read         (o_csr_read),
      .o_csr_rs1_imm      (o_csr_rs1_imm),
      .o_wb_src           (riscv_pu_instr_decode__wb_src),
      .o_valid_instr      (riscv_pu_instr_decode__valid_instr),
      .o_flush            (riscv_pu_instr_decode__flush),
      .o_pc               (riscv_pu_instr_decode__pc),
      .o_imm_data         (riscv_pu_instr_decode__imm_data),
      .o_rs1_addr         (riscv_pu_instr_decode__rs1_addr),
      .o_rs2_addr         (riscv_pu_instr_decode__rs2_addr),
      .o_rd_addr          (riscv_pu_instr_decode__rd_addr)
    );
  
  riscv_pu_register #(
    .DATA_WIDTH (DATA_WIDTH)
    ) riscv_pu_register (
      .clk                (clk),
      .nreset             (nreset),
      .enable             (enable),
      .i_stall_rd         (i_stall_rd_reg),
      .i_stall_wr         (i_stall_wr_reg),
      .i_rd_write         (riscv_pu_memory_adapter__rd_write),
      .i_ras_read         (i_ras_read),
      .i_rd_write_data    (riscv_pu_memory_adapter__rd_write_data),
      .i_ras_data         (i_ras_data),
      .i_rs1_addr         (i_instr[19:15]),
      .i_rs2_addr         (i_instr[24:20]),
      .i_rd_addr          (riscv_pu_memory_adapter__rd_addr),
      .o_rs1_data         (riscv_pu_register__rs1_data),
      .o_rs2_data         (riscv_pu_register__rs2_data)
    );
  
  riscv_pu_execution_unit #(
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH)
    ) riscv_pu_execution_unit (
      .clk                (clk),
      .nreset             (nreset),
      .enable             (enable),
      .i_stall            (i_stall_ex),
      .i_flush_id         (riscv_pu_instr_decode__flush),
      .i_flush_ex         (i_flush_ex),
      .i_alu_op           (riscv_pu_instr_decode__alu_op),
      .i_alu_src          (riscv_pu_instr_decode__alu_src),
      .i_imm              (riscv_pu_instr_decode__imm),             
      .i_width            (riscv_pu_instr_decode__width),
      .i_branch_op        (riscv_pu_instr_decode__branch_op),
      .i_pc_src           (riscv_pu_instr_decode__pc_src),
      .i_jump             (riscv_pu_instr_decode__jump),
      .i_branch           (riscv_pu_instr_decode__branch),
      .i_add_sub_srl_sra  (riscv_pu_instr_decode__add_sub_srl_sra),
      .i_rd_write         (riscv_pu_instr_decode__rd_write),
      .i_read             (riscv_pu_instr_decode__read),
      .i_write            (riscv_pu_instr_decode__write),
      .i_wb_src           (riscv_pu_instr_decode__wb_src),
      .i_valid_instr      (riscv_pu_instr_decode__valid_instr),
      .i_ex_rd_write      (riscv_pu_execution_unit__rd_write),
      .i_mem_rd_write     (riscv_pu_memory_adapter__rd_write),
      .i_pc               (riscv_pu_instr_decode__pc),
      .i_alu_data         (riscv_pu_execution_unit__alu_data),
      .i_wr_data          (riscv_pu_memory_adapter__rd_write_data),
      .i_rs1_data         (riscv_pu_register__rs1_data),
      .i_rs2_data         (riscv_pu_register__rs2_data),
      .i_imm_data         (riscv_pu_instr_decode__imm_data),
      .i_rs1_addr         (riscv_pu_instr_decode__rs1_addr),
      .i_rs2_addr         (riscv_pu_instr_decode__rs2_addr),
      .i_rd_addr          (riscv_pu_instr_decode__rd_addr),
      .i_ex_rd_addr       (riscv_pu_execution_unit__rd_addr),
      .i_mem_rd_addr      (riscv_pu_memory_adapter__rd_addr),
      .o_width            (riscv_pu_execution_unit__width),
      .o_jump             (riscv_pu_execution_unit__jump),
      .o_rd_write         (riscv_pu_execution_unit__rd_write),
      .o_read             (riscv_pu_execution_unit__read),
      .o_write            (riscv_pu_execution_unit__write),
      .o_wb_src           (riscv_pu_execution_unit__wb_src),
      .o_valid_instr      (riscv_pu_execution_unit__valid_instr),
      .o_jump_branch      (riscv_pu_execution_unit__jump_branch),
      .o_flush            (riscv_pu_execution_unit__flush),
      .o_pc               (riscv_pu_execution_unit__pc),
      .o_alu_data         (riscv_pu_execution_unit__alu_data),
      .o_rs2_data         (riscv_pu_execution_unit__rs2_data),
      .o_rs1_addr         (riscv_pu_execution_unit__rs1_addr),
      .o_rd_addr          (riscv_pu_execution_unit__rd_addr)
    );
  
  riscv_pu_memory_access_unit #(
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH)
    ) riscv_pu_memory_access_unit (
      .clk                (clk),
      .nreset             (nreset),
      .enable             (enable),
      .i_stall            (i_stall_mem),
      .i_flush            (riscv_pu_execution_unit__flush),
      .i_width            (riscv_pu_execution_unit__width),
      .i_rd_write         (riscv_pu_execution_unit__rd_write),
      .i_read             (riscv_pu_execution_unit__read),
      .i_write            (riscv_pu_execution_unit__write),
      .i_wb_src           (riscv_pu_execution_unit__wb_src),
      .i_valid_instr      (riscv_pu_execution_unit__valid_instr),
      .i_mem_wr_ready     (i_mem_wr_ready),
      .i_mem_rd_valid     (i_mem_rd_valid),
      .i_desc_wready      (i_desc_wready),
      .i_resp_rready      (i_resp_rready),
      .i_alu_data         (riscv_pu_execution_unit__alu_data),
      .i_rs2_data         (riscv_pu_execution_unit__rs2_data),
      .i_mem_rd_data      (i_mem_rd_data),
      .i_resp_data        (i_resp_data),
      .i_rd_addr          (riscv_pu_execution_unit__rd_addr),
      .o_rd_write         (riscv_pu_memory_adapter__rd_write),
      .o_mem_rd_ready     (o_mem_rd_ready),
      .o_mem_wr_valid     (o_mem_wr_valid),
      .o_desc_wr          (o_desc_wr),
      .o_resp_rd          (o_resp_rd),
      .o_valid_instr      (riscv_pu_memory_adapter__valid_instr),
      .o_flush            (riscv_pu_memory_adapter__flush),
      .o_mem_wr_data      (o_mem_wr_data),
      .o_desc_data        (o_desc_data),
      .o_rd_write_data    (riscv_pu_memory_adapter__rd_write_data),      
      .o_mem_wr_strb      (o_mem_wr_strb),
      .o_mem_addr         (o_mem_addr),
      .o_rd_addr          (riscv_pu_memory_adapter__rd_addr)
    );
    
  assign o_ex_jump = riscv_pu_execution_unit__jump;
  assign o_jump_branch = riscv_pu_execution_unit__jump_branch;
  assign o_flush_if = riscv_pu_instr_fetch__flush;
  assign o_ex_pc = riscv_pu_execution_unit__alu_data;
  assign o_rd_write = riscv_pu_memory_adapter__rd_write;
  assign o_ex_rs1_addr = riscv_pu_execution_unit__rs1_addr;
  assign o_ex_rd_addr = riscv_pu_execution_unit__rd_addr;
  
endmodule
