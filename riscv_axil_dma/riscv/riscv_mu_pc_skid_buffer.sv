import riscv_pkg::*;

module riscv_mu_skid_buffer #(
  parameter DATA_WIDTH = 64,
  parameter INSTR_WIDTH = 32
  )(
  input clk,
  input nreset,
  input enable,
  
  input i_stall,
  
  input i_valid,
  input i_ras_read,
  
  input [DATA_WIDTH - 1:0] i_pc,
  
  output o_ras_read,
  
  output [DATA_WIDTH - 1:0] o_pc
  );
  
  wire mu_skid_buffer_en_c;
  
  reg ras_read_r;
  
  reg [DATA_WIDTH - 1:0] pc_r;
  
  assign mu_skid_buffer_en_c = (!i_stall) && i_valid && enable;
  always_ff @(posedge clk or negedge nreset) begin
    if (!nreset) begin
      pc_r <= {DATA_WIDTH{1'b0}};
    end else if (mu_skid_buffer_en_c) begin
      pc_r <= i_pc;
    end
  end
  
  always_ff @(posedge clk or negedge nreset) begin
    if (!nreset) begin
      ras_read_r <= 1'b0;
    end else if (enable) begin
      ras_read_r <= i_ras_read;
    end
  end
  
  assign o_ras_read = ras_read_r;
  assign o_pc = pc_r;
  
endmodule
