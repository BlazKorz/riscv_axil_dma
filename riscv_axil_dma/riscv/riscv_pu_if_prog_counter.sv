import riscv_pkg::*;

module riscv_if_prog_counter #(
  parameter ADDR_WIDTH = 64,
  parameter DATA_WIDTH = 64
  )(
  input clk,
  input nreset,
  input enable,
  
  input i_stall,
  
  input i_interr,
  input i_jump_branch,
  
  input [DATA_WIDTH - 1:0] i_pc,
  
  input [ADDR_WIDTH - 1:0] i_interr_addr,
  
  output o_read_instr,
  
  output [DATA_WIDTH - 1:0] o_pc
  );
  
  wire prog_counter_en_c;
  
  wire [DATA_WIDTH - 1:0]  pc_c;
  
  reg read_instr_r;
  
  reg [DATA_WIDTH - 1:0]  pc_r;
  
  assign prog_counter_en_c = (!i_stall) && enable;
  assign pc_c = (i_interr) ?      (i_interr_addr) :
                (i_jump_branch) ? (i_pc) :
                                  (pc_r + 'h4);
  always_ff @(posedge clk or negedge nreset) begin
    if (!nreset) begin
      pc_r <= {DATA_WIDTH{1'b0}};
    end else if (prog_counter_en_c) begin
      pc_r <= pc_c;
    end
  end
  
  assign o_read_instr = (!i_stall) &&  1'b1;
  assign o_pc = pc_r;
  
endmodule
