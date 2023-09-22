import riscv_pkg::*;

module riscv_cache #(
  parameter ADDR_WIDTH = 64,
  parameter DATA_WIDTH = 64
  )(
  input clk,
  input nreset,
  input enable,
  
  input i_read,
  input i_write,
  
  input [DATA_WIDTH - 1:0] i_data,
  
  input [ADDR_WIDTH - 1:0] i_rd_addr,
  input [ADDR_WIDTH - 1:0] i_wr_addr,
  
  output [DATA_WIDTH - 1:0] o_data
  );
  
  wire cache_rd_en_c;
  wire cache_wr_en_c;
  
  reg [DATA_WIDTH - 1:0] data_r;
  reg [DATA_WIDTH - 1:0] cache_r [0:255];
  
  assign cache_wr_en_c = i_write && enable;
  always_ff @(posedge clk) begin
    if (cache_wr_en_c) begin
      cache_r[i_wr_addr] <= i_data;
    end
  end
  
  assign cache_rd_en_c = i_read && enable;
  always_ff @(posedge clk or negedge nreset) begin
    if (!nreset) begin
      data_r <= {DATA_WIDTH{1'h0}};
    end else if (cache_rd_en_c) begin
      data_r <= cache_r[i_rd_addr];
    end
  end
  
  assign o_data = data_r;
  
endmodule
