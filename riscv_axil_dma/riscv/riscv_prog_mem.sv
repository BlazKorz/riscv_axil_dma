module riscv_prog_mem #(
  parameter ADDR_WIDTH = 64,
  parameter INSTR_WIDTH = 32
  )(  
  input clk,
  input nreset,
  input enable,
  
  input i_read,
  
  input [ADDR_WIDTH - 1:0] i_pc,
  
  output reg o_valid,
  
  output reg [INSTR_WIDTH - 1:0] o_instr
  );
  
  wire prog_mem_en_c;
  
  reg [INSTR_WIDTH - 1:0] prog_r [0:4095];
  
  initial begin
    $readmemb("program.mem", prog_r);
  end
  
  assign prog_mem_en_c = i_read && enable;
  always @(posedge clk or negedge nreset) begin
    if (!nreset) begin
      o_instr <= {INSTR_WIDTH{1'h0}};
    end else if (prog_mem_en_c) begin
      o_instr <= prog_r[i_pc[ADDR_WIDTH - 1:2]];
    end
  end
  
  always @(posedge clk or negedge nreset) begin
    if (!nreset) begin
      o_valid <= 1'h0;
    end else if (enable) begin
      o_valid <= i_read;
    end
  end
  
  wire unused_ok = &{i_pc[1:0]};
  
endmodule
