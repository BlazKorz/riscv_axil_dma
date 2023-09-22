import riscv_pkg::*;

module riscv_pu_register #(
  parameter DATA_WIDTH = 64
  )(
  input clk,
  input nreset,
  input enable,
  
  input i_stall_rd,
  input i_stall_wr,
  
  input i_rd_write,
  input i_ras_read,
  
  input [DATA_WIDTH - 1:0] i_rd_write_data,
  input [DATA_WIDTH - 1:0] i_ras_data,
  
  input [4:0] i_rs1_addr,
  input [4:0] i_rs2_addr,
  input [4:0] i_rd_addr,
  
  output [DATA_WIDTH - 1:0] o_rs1_data,
  output [DATA_WIDTH - 1:0] o_rs2_data
  );
  
  wire register_rd_en_c;
  wire register_wr_en_c;
  
  wire [DATA_WIDTH - 1:0] register_c;
  
  wire [4:0] wr_addr_c;
  
  reg  [DATA_WIDTH - 1:0] rs1_data_r;
  wire [DATA_WIDTH - 1:0] rs1_data_c;
  reg  [DATA_WIDTH - 1:0] rs2_data_r;
  wire [DATA_WIDTH - 1:0] rs2_data_c;
  
  reg [DATA_WIDTH - 1:0] register_r [0:31] = '{default:0};;
  
  assign wr_addr_c = (i_ras_read) ? (LINK_1) : (i_rd_addr);
  
  assign register_wr_en_c = (i_rd_write || i_ras_read) && (!i_stall_wr) && enable;
  assign register_c = (i_ras_read) ? (i_ras_data) : (i_rd_write_data);
  always_ff @(posedge clk) begin
    if (register_wr_en_c) begin
      register_r[wr_addr_c] <= register_c;
    end
  end
  
  assign register_rd_en_c = (!i_stall_rd) && enable;
  assign rs1_data_c = (register_wr_en_c && (wr_addr_c == i_rs1_addr)) ? register_c :
                                                                        register_r[i_rs1_addr];
  assign rs2_data_c = (register_wr_en_c && (wr_addr_c == i_rs2_addr)) ? register_c :
                                                                        register_r[i_rs2_addr];
  always_ff @(posedge clk or negedge nreset) begin
    if (!nreset) begin
      rs1_data_r <= {DATA_WIDTH{1'h0}};
      rs2_data_r <= {DATA_WIDTH{1'h0}};
    end else if (register_rd_en_c) begin      
      rs1_data_r <= rs1_data_c;
      rs2_data_r <= rs2_data_c;
    end
  end
  
  assign o_rs1_data = rs1_data_r;
  assign o_rs2_data = rs2_data_r;
  
endmodule
