import riscv_pkg::*;

module riscv_mem_stage #(
  parameter ADDR_WIDTH = 64,
  parameter DATA_WIDTH = 64,
  parameter STRB_WIDTH = DATA_WIDTH /8
  )(
  input clk,
  input nreset,
  input enable,
  
  input i_stall,
  input i_flush,
  
  input i_rd_write,
  input i_read,
  input i_write,
  input i_wb_src,
  input i_valid_instr,
  input i_mem_wr_ready,
  input i_mem_rd_valid,
  input i_desc_wready,
  input i_resp_rready,
  
  input [DATA_WIDTH - 1:0] i_alu_data,
  input [DATA_WIDTH - 1:0] i_rs2_data,
  input [DATA_WIDTH - 1:0] i_mem_rd_data,
  input [9:0] i_resp_data,
  input [STRB_WIDTH - 1:0] i_mem_wr_strb,
  
  input [4:0] i_rd_addr,
  
  output reg o_rd_write,
  output reg o_mem_rd_ready,
  output reg o_mem_wr_valid,
  output reg o_desc_wr,
  output reg o_resp_rd,
  output reg o_valid_instr,
  output reg o_flush,
  
  output reg [DATA_WIDTH - 1:0] o_rd_write_data,
  output reg [DATA_WIDTH - 1:0] o_mem_wr_data,
  output reg [60:0] o_desc_data,
  output reg [STRB_WIDTH - 1:0] o_mem_wr_strb,
  
  output reg [ADDR_WIDTH - 1:0] o_mem_addr,
  output reg [4:0] o_rd_addr
  );
  
  wire mem_stage_en_c;
  
  wire desc_c;
  
  wire rd_write_c;
  wire valid_instr_c;
  
  wire [DATA_WIDTH - 1:0] rd_write_data_c;
  
  wire                    mem_wr_valid_c;
  reg                     mem_wr_valid_r;
  wire                    mem_rd_ready_c;
  reg                     mem_rd_ready_r;
  wire [DATA_WIDTH - 1:0] mem_addr_c;
  reg  [DATA_WIDTH - 1:0] mem_addr_r;
  wire [DATA_WIDTH - 1:0] mem_wr_data_c;
  reg  [DATA_WIDTH - 1:0] mem_wr_data_r;
  wire [STRB_WIDTH - 1:0] mem_wr_strb_c;
  reg  [STRB_WIDTH - 1:0] mem_wr_strb_r;
  
  assign desc_c = i_alu_data[ADDR_WIDTH + 1];
  
  assign mem_stage_en_c  = (!i_stall) && enable;
  assign rd_write_c      = (i_flush) ? ('h0) : (i_rd_write);
  assign valid_instr_c   = (i_flush) ? ('h0) : (i_valid_instr);
  assign rd_write_data_c = (i_wb_src) ? (i_alu_data) : 
                           (desc_c) ?   (i_resp_data) :
                                        (i_mem_rd_data);
  always_ff @(posedge clk or negedge nreset) begin
    if (!nreset) begin
      o_rd_write      <= 1'h0;
      o_valid_instr   <= 1'h0;
      o_flush         <= 1'h0;
      o_rd_write_data <= {DATA_WIDTH{1'h0}};
      o_rd_addr       <= 4'h0;
    end else if (mem_stage_en_c) begin
      o_rd_write      <= rd_write_c;
      o_valid_instr   <= valid_instr_c;
      o_flush         <= i_flush;
      o_rd_write_data <= rd_write_data_c;
      o_rd_addr       <= i_rd_addr;
    end
  end
  
  assign mem_addr_c    = (mem_wr_valid_r || mem_rd_ready_r) ? mem_addr_r : i_alu_data;
  assign mem_wr_data_c = (mem_wr_valid_r) ? mem_wr_data_r : i_rs2_data;
  assign mem_wr_strb_c = (mem_wr_valid_r) ? mem_wr_strb_r : i_mem_wr_strb;
  always_ff @(posedge clk or negedge nreset) begin
    if (!nreset) begin
      mem_addr_r    <= {ADDR_WIDTH{1'h0}};
      mem_wr_data_r <= {DATA_WIDTH{1'h0}};
      mem_wr_strb_r <= {STRB_WIDTH{1'h0}};
    end else if (enable) begin
      mem_addr_r    <= mem_addr_c;
      mem_wr_data_r <= mem_wr_data_c;
      mem_wr_strb_r <= mem_wr_strb_c;
    end
  end
  
  assign mem_wr_valid_c = (mem_wr_valid_r) ?
                          (i_mem_wr_ready) ?    1'h0 :
                                                mem_wr_valid_r:
                          (i_write & ~desc_c) ? 1'h1 :
                                                1'h0;
  always_ff @(posedge clk or negedge nreset) begin
    if (!nreset) begin
      mem_wr_valid_r <= 1'h0;
    end else if (enable) begin
      mem_wr_valid_r <= mem_wr_valid_c;
    end
  end
  
  assign mem_rd_ready_c = (mem_rd_ready_r) ?
                          (i_mem_rd_valid) ?   1'h0 :
                                               mem_rd_ready_r:
                          (i_read & ~desc_c) ? 1'h1 :
                                               1'h0;
  always_ff @(posedge clk or negedge nreset) begin
    if (!nreset) begin
      mem_rd_ready_r <= 1'h0;
    end else if (enable) begin
      mem_rd_ready_r <= mem_rd_ready_c;
    end
  end
  
  assign o_mem_wr_valid = mem_wr_valid_c;
  assign o_mem_rd_ready = mem_rd_ready_c;
  assign o_desc_wr = (i_write && i_desc_wready && desc_c);
  assign o_resp_rd = (i_read && i_resp_rready && desc_c);
  assign o_mem_addr = mem_addr_c;
  assign o_mem_wr_data = mem_wr_data_c;
  assign o_desc_data = mem_wr_data_c[60:0];
  assign o_mem_wr_strb = mem_wr_strb_c;
  
endmodule
