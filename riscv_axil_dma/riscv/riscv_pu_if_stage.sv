import riscv_pkg::*;

module riscv_if_stage #(
  parameter DATA_WIDTH = 64
  )(
  input clk,
  input nreset,
  input enable,
  
  input i_stall,
  input i_flush,
  
  output reg o_flush
  );
  
  wire if_stage_en_c;
  
  assign if_stage_en_c = (!i_stall) && enable;
  always_ff @(posedge clk or negedge nreset) begin
    if (!nreset) begin
      o_flush <= 1'b0;
    end else if (if_stage_en_c) begin
      o_flush <= i_flush;
    end
  end
  
endmodule
