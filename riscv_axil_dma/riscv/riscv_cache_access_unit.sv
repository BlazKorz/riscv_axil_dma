import riscv_pkg::*;

module riscv_mu_cache_access_unit #(
  parameter ADDR_WIDTH = 64,
  parameter DATA_WIDTH = 64,
  parameter RAS_DEPTH = 16,
  parameter RAS_FSM_WIDTH = 3,
  parameter SU_FSM_WIDTH = 3
  )(
  input clk,
  input nreset,
  input enable,
  
  input i_ex_stall,
  
  input i_ex_jump,
  
  input [DATA_WIDTH - 1:0] i_pc,
  
  input [4:0] i_ex_rs1_addr,
  input [4:0] i_ex_rd_addr,
  
  output o_cache_write,
  output o_cache_read,
  output o_ras_read,
  
  output [DATA_WIDTH - 1:0] o_cache_wr_data,
  
  output [ADDR_WIDTH - 1:0] o_cache_wr_addr,
  output [ADDR_WIDTH - 1:0] o_cache_rd_addr
  );
  
  wire                       riscv_ca_return_addr_stack__write;
  wire                       riscv_ca_return_addr_stack__read;
  wire [RAS_FSM_WIDTH - 1:0] riscv_ca_return_addr_stack__fsm_status;
  wire [ADDR_WIDTH - 1:0]    riscv_ca_return_addr_stack__wr_addr;
  wire [ADDR_WIDTH - 1:0]    riscv_ca_return_addr_stack__rd_addr;
  wire [SU_FSM_WIDTH - 1:0]  riscv_ca_stacking_unit__fsm_status;
  
  reg [DATA_WIDTH - 1:0] cache_wr_data_r;
  
  riscv_ca_return_addr_stack #(
    .ADDR_WIDTH    (ADDR_WIDTH),
    .RAS_DEPTH     (RAS_DEPTH),
    .RAS_FSM_WIDTH (RAS_FSM_WIDTH)
    ) riscv_ca_return_addr_stack (
      .clk           (clk),
      .nreset        (nreset),
      .enable        (enable),
      .i_ex_stall    (i_id_stall),
      .i_abort       (1'b0),
      .i_ex_jump     (i_ex_jump),
      .i_ex_rs1_addr (i_ex_rs1_addr),
      .i_ex_rd_addr  (i_ex_rd_addr),
      .i_wr_addr     (riscv_ca_return_addr_stack__wr_addr),
      .o_write       (riscv_ca_return_addr_stack__write),
      .o_read        (riscv_ca_return_addr_stack__read),
      .o_fsm_status  (riscv_ca_return_addr_stack__fsm_status),
      .o_wr_addr     (riscv_ca_return_addr_stack__wr_addr),
      .o_rd_addr     (riscv_ca_return_addr_stack__rd_addr)
    );
    
  riscv_ca_stacking_unit #(
    .ADDR_WIDTH   (ADDR_WIDTH),
    .SU_FSM_WIDTH (SU_FSM_WIDTH)
    ) riscv_ca_stacking_unit (
      .clk          (clk),
      .nreset       (nreset),
      .enable       (enable),
      .i_abort      (1'b0),
      .i_data       (),
      .o_fsm_status (riscv_ca_stacking_unit__fsm_status)
    );
    
  always_ff @(posedge clk or negedge nreset) begin
    if (!nreset) begin
      cache_wr_data_r <= {DATA_WIDTH{1'b0}};
    end else if (enable) begin
      cache_wr_data_r <= i_pc;
    end
  end
  
  assign o_cache_write = riscv_ca_return_addr_stack__write;
  assign o_cache_read = riscv_ca_return_addr_stack__read;
  assign o_ras_read = riscv_ca_return_addr_stack__read;
  assign o_cache_wr_data = cache_wr_data_r;
  assign o_cache_wr_addr = riscv_ca_return_addr_stack__wr_addr;
  assign o_cache_rd_addr = riscv_ca_return_addr_stack__rd_addr;
  
endmodule
