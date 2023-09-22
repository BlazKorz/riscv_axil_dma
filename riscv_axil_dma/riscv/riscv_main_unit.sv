import riscv_pkg::*;

module riscv_main_unit #(
  parameter ADDR_WIDTH = 64,
  parameter DATA_WIDTH = 64,
  parameter INSTR_WIDTH = 32,
  parameter RAS_DEPTH = 16,
  parameter STRB_WIDTH = DATA_WIDTH / 8
  )(
  input clk,
  input nreset,
  input enable,
  
  input i_instr_valid,
  input [INSTR_WIDTH - 1:0] i_instr,
  output [ADDR_WIDTH - 1:0] o_pc,
  output o_read_instr,
  
  input i_desc_wready,
  output [60:0] o_desc_data,
  output o_desc_wr,
  
  input [9:0] i_resp_data,
  input i_resp_rready,
  output o_resp_rd,
  
  output o_mem_wr_valid,
  output [STRB_WIDTH - 1:0] o_mem_wr_strb,
  output [DATA_WIDTH - 1:0] o_mem_wr_data,
  input i_mem_wr_ready,
  
  output o_mem_rd_ready,
  input [DATA_WIDTH - 1:0] i_mem_rd_data,
  input i_mem_rd_valid,
  
  output [ADDR_WIDTH - 1:0] o_mem_addr,
  
  output o_busy,
  
  input [DATA_WIDTH - 1:0] i_cache_data,
  output o_cache_read,
  output o_cache_write,
  output [DATA_WIDTH - 1:0] o_cache_wr_data,
  output [ADDR_WIDTH - 1:0] o_cache_rd_addr,
  output [ADDR_WIDTH - 1:0] o_cache_wr_addr
  );
  
  wire                     riscv_mu_hazard_detection__stall_if;
  wire                     riscv_mu_hazard_detection__stall_id;
  wire                     riscv_mu_hazard_detection__stall_rd_reg;
  wire                     riscv_mu_hazard_detection__stall_wr_reg;
  wire                     riscv_mu_hazard_detection__stall_ex;
  wire                     riscv_mu_hazard_detection__stall_mem;
  wire                     riscv_mu_hazard_detection__flush_if;
  wire                     riscv_mu_hazard_detection__flush_id;
  wire                     riscv_mu_hazard_detection__flush_ex;
  wire                     riscv_mu_cache_access_unit__ras_read;
  wire                     riscv_mu_skid_buffer__ras_read;
  wire [DATA_WIDTH - 1:0]  riscv_mu_skid_buffer__pc;
  wire [1:0]               riscv_mu_processing_unit__id_csr_op;
  wire                     riscv_mu_processing_unit__id_csr_write;
  wire                     riscv_mu_processing_unit__id_csr_read;
  wire                     riscv_mu_processing_unit__id_csr_rs1_imm;
  wire                     riscv_mu_processing_unit__mem_wr_valid;
  wire                     riscv_mu_processing_unit__mem_rd_ready;
  wire                     riscv_mu_processing_unit__ex_jump;
  wire                     riscv_mu_processing_unit__mem_rd_write;
  wire                     riscv_mu_processing_unit__ex_jump_branch;
  wire                     riscv_mu_processing_unit__if_flush_if;
  wire [DATA_WIDTH - 1:0]  riscv_mu_processing_unit__if_pc;
  wire [DATA_WIDTH - 1:0]  riscv_mu_processing_unit__ex_pc;
  wire [4:0]               riscv_mu_processing_unit__ex_rs1_addr;
  wire [4:0]               riscv_mu_processing_unit__ex_rd_addr;
  wire [DATA_WIDTH - 1:0]  riscv_mu_csr_access_unit__csr_data;
  
  riscv_mu_status_manager #(
    
    ) riscv_mu_status_manager (
      .clk             (clk),
      .nreset          (nreset),
      .enable          (enable),
      .i_flush_if      (riscv_mu_processing_unit__if_flush_if),
      .o_busy          (o_busy)
    );
    
  riscv_mu_hazard_detection_unit #(
    
    ) riscv_mu_hazard_detection_unit (
      .clk             (clk),
      .nreset          (nreset),
      .enable          (enable),
      .i_mem_wr_ready  (i_mem_wr_ready),
      .i_mem_wr_valid  (riscv_mu_processing_unit__mem_wr_valid),
      .i_mem_rd_valid  (i_mem_rd_valid),
      .i_mem_rd_ready  (riscv_mu_processing_unit__mem_rd_ready),
      .i_jump_branch   (riscv_mu_processing_unit__ex_jump_branch),
      .o_stall_if      (riscv_mu_hazard_detection__stall_if),
      .o_stall_id      (riscv_mu_hazard_detection__stall_id),
      .o_stall_rd_reg  (riscv_mu_hazard_detection__stall_rd_reg),
      .o_stall_wr_reg  (riscv_mu_hazard_detection__stall_wr_reg),
      .o_stall_ex      (riscv_mu_hazard_detection__stall_ex),
      .o_stall_mem     (riscv_mu_hazard_detection__stall_mem),
      .o_flush_if      (riscv_mu_hazard_detection__flush_if),
      .o_flush_id      (riscv_mu_hazard_detection__flush_id),
      .o_flush_ex      (riscv_mu_hazard_detection__flush_ex)
    );
    
  riscv_mu_cache_access_unit #(
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH),
    .RAS_DEPTH  (RAS_DEPTH)
    ) riscv_mu_cache_access_unit (
      .clk             (clk),
      .nreset          (nreset),
      .enable          (enable),
      .i_ex_stall      (1'h0),
      .i_ex_jump       (riscv_mu_processing_unit__ex_jump),
      .i_pc            (riscv_mu_processing_unit__ex_pc),
      .i_ex_rs1_addr   (riscv_mu_processing_unit__ex_rs1_addr),
      .i_ex_rd_addr    (riscv_mu_processing_unit__ex_rd_addr),
      .o_cache_write   (o_cache_write),
      .o_cache_read    (o_cache_read),
      .o_ras_read      (riscv_mu_cache_access_unit__ras_read),
      .o_cache_wr_data (o_cache_wr_data),
      .o_cache_wr_addr (o_cache_wr_addr),
      .o_cache_rd_addr (o_cache_rd_addr)
    );
    
  riscv_mu_skid_buffer #(
    .DATA_WIDTH  (DATA_WIDTH),
    .INSTR_WIDTH (INSTR_WIDTH)
    ) riscv_mu_skid_buffer (
      .clk             (clk),
      .nreset          (nreset),
      .enable          (enable),
      .i_stall         (riscv_mu_hazard_detection__stall_if),
      .i_valid         (i_instr_valid),
      .i_ras_read      (riscv_mu_cache_access_unit__ras_read),
      .i_pc            (riscv_mu_processing_unit__if_pc),
      .o_ras_read      (riscv_mu_skid_buffer__ras_read),
      .o_pc            (riscv_mu_skid_buffer__pc)
    );
    
  riscv_mu_processing_unit #(
    .ADDR_WIDTH  (ADDR_WIDTH),
    .DATA_WIDTH  (DATA_WIDTH),
    .INSTR_WIDTH (INSTR_WIDTH)
    ) riscv_mu_processing_unit (
      .clk             (clk),
      .nreset          (nreset),
      .enable          (enable),
      .i_stall_if      (riscv_mu_hazard_detection__stall_if),
      .i_stall_id      (riscv_mu_hazard_detection__stall_id),
      .i_stall_rd_reg  (riscv_mu_hazard_detection__stall_rd_reg),
      .i_stall_wr_reg  (riscv_mu_hazard_detection__stall_wr_reg),
      .i_stall_ex      (riscv_mu_hazard_detection__stall_ex),
      .i_stall_mem     (riscv_mu_hazard_detection__stall_mem),
      .i_flush_if      (riscv_mu_hazard_detection__flush_if),
      .i_flush_id      (riscv_mu_hazard_detection__flush_id),
      .i_flush_ex      (riscv_mu_hazard_detection__flush_ex),
      .i_interr        (1'h0),
      .i_mem_wr_ready  (i_mem_wr_ready),
      .i_mem_rd_valid  (i_mem_rd_valid),
      .i_desc_wready   (i_desc_wready),
      .i_resp_rready   (i_resp_rready),
      .i_ras_read      (riscv_mu_skid_buffer__ras_read),
      .i_instr         (i_instr),
      .i_pc            (riscv_mu_skid_buffer__pc),
      .i_mem_rd_data   (i_mem_rd_data),
      .i_resp_data     (i_resp_data),
      .i_ras_data      (i_cache_data),
      .i_interr_addr   (16'b0),
      .o_ex_jump       (riscv_mu_processing_unit__ex_jump),
      .o_csr_op        (riscv_mu_processing_unit__id_csr_op),
      .o_mem_rd_ready  (riscv_mu_processing_unit__mem_rd_ready),
      .o_mem_wr_valid  (riscv_mu_processing_unit__mem_wr_valid),
      .o_desc_wr       (o_desc_wr),
      .o_csr_write     (riscv_mu_processing_unit__id_csr_write),
      .o_csr_read      (riscv_mu_processing_unit__id_csr_read),
      .o_csr_rs1_imm   (riscv_mu_processing_unit__id_csr_rs1_imm),
      .o_read_instr    (o_read_instr),
      .o_jump_branch   (riscv_mu_processing_unit__ex_jump_branch),
      .o_flush_if      (riscv_mu_processing_unit__if_flush_if),
      .o_if_pc         (riscv_mu_processing_unit__if_pc),
      .o_ex_pc         (riscv_mu_processing_unit__ex_pc),
      .o_mem_wr_data   (o_mem_wr_data),
      .o_desc_data     (o_desc_data),
      .o_resp_rd       (o_resp_rd),
      .o_mem_wr_strb   (o_mem_wr_strb),
      .o_mem_addr      (o_mem_addr),
      .o_ex_rs1_addr   (riscv_mu_processing_unit__ex_rs1_addr),
      .o_ex_rd_addr    (riscv_mu_processing_unit__ex_rd_addr)
    );
    
  assign o_mem_rd_ready = riscv_mu_processing_unit__mem_rd_ready;
  assign o_mem_wr_valid = riscv_mu_processing_unit__mem_wr_valid;
  assign o_pc = riscv_mu_processing_unit__if_pc;

endmodule
