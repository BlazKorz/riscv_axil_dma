import riscv_pkg::*;

module riscv_ex_arithmetic_logic_unit #(
  parameter DATA_WIDTH = 64
  )( 
  input [2:0] i_alu_op,
  input [2:0] i_alu_src,
  input [2:0] i_width,
  input [1:0] i_mux1_src,
  input [1:0] i_mux2_src,
  input [1:0] i_mux3_src,
  
  input i_add_sub_srl_sra,
  
  input i_read,
  input i_write,
  
  input [DATA_WIDTH - 1:0] i_pc,
  input [DATA_WIDTH - 1:0] i_alu_data,
  input [DATA_WIDTH - 1:0] i_wr_data,
  input [DATA_WIDTH - 1:0] i_rs1_data,
  input [DATA_WIDTH - 1:0] i_rs2_data,
  input [DATA_WIDTH - 1:0] i_imm_data,
  
  output o_carry,
  output o_zero,
  
  output [DATA_WIDTH - 1:0] o_alu_data,
  output [DATA_WIDTH - 1:0] o_rs1_data,
  output [DATA_WIDTH - 1:0] o_rs2_data
  );
  
  wire [$clog2(DATA_WIDTH) - 1:0] shamt_c;
  wire [2:0] width_c;
  wire carry_c;
  wire sign_c;
  wire carry_sign_c;
  wire carry_unsigned_c;
  
  wire [DATA_WIDTH - 1:0] value1_c;
  wire [DATA_WIDTH - 1:0] value2_c;
  wire [DATA_WIDTH - 1:0] value3_c;
  wire [DATA_WIDTH:0] sub_value_c;
  
  wire [DATA_WIDTH - 1:0] alu_result_c;
  wire [DATA_WIDTH - 1:0] srl_sra_value_c;
  
  assign value1_c = (i_mux1_src == 2'h1) ?                          (i_alu_data) :
                    (i_mux1_src == 2'h2) ?                          (i_wr_data) :
                    ((i_alu_src == 3'h4) || (i_alu_src ==  3'h5)) ? (i_pc) :
                    (i_alu_src == 3'h7) ?                           ({DATA_WIDTH{1'h0}}) :
                                                                    (i_rs1_data);
  
  assign value2_c = (i_mux2_src == 2'h1) ?                                                (i_alu_data) :
                    (i_mux2_src == 2'h2) ?                                                (i_wr_data) :
                    ((i_alu_src == 3'h1) || (i_alu_src == 3'h4) || (i_alu_src == 3'h7)) ? (i_imm_data) :
                    (i_alu_src == 3'h5) ?                                                 ('h4) :
                                                                                          (i_rs2_data);
  
  assign value3_c = (i_mux3_src == 2'h1) ?                                                (i_alu_data) :
                    (i_mux3_src == 2'h2) ?                                                (i_wr_data) :
                    ((i_alu_src == 3'h1) || (i_alu_src == 3'h4) || (i_alu_src == 3'h7)) ? (i_imm_data) :
                    (i_alu_src == 3'h5) ?                                                 ('h4) :
                                                                                          (i_rs2_data);
  
  assign shamt_c = value2_c[$clog2(DATA_WIDTH) - 1:0];
  assign sub_value_c = value1_c - value2_c;
  assign carry_c = sub_value_c[DATA_WIDTH];
  assign carry_sign_c = (value1_c[DATA_WIDTH - 1] ^  value2_c[DATA_WIDTH - 1]) ? (~carry_c) : (carry_c);
  assign carry_unsigned_c = value1_c < value2_c;
  
  assign srl_sra_value_c = (i_width[1:0] == MEM_WIDTH_DWORD) ?
                           (i_add_sub_srl_sra) ?                $signed(value1_c[63:0]) >>> shamt_c[5:0] :
                                                                value1_c[63:0] >> shamt_c[5:0] :
                           (i_width[1:0] == MEM_WIDTH_WORD) ?
                           (i_add_sub_srl_sra) ?                $signed(value1_c[31:0]) >>> shamt_c[4:0] :
                                                                value1_c[31:0] >> shamt_c[4:0] :
                           {DATA_WIDTH{1'h0}};
  
  assign alu_result_c = (i_alu_op[2:0] == ALU_OP_ADD_SUB) ?
                        (i_add_sub_srl_sra) ?                sub_value_c[DATA_WIDTH - 1:0] :
                                                             value1_c + value2_c :
                        (i_alu_op[2:0] == ALU_OP_SLL) ?     (value1_c << shamt_c) :
                        (i_alu_op[2:0] == ALU_OP_SLT) ?     ({{DATA_WIDTH{1'h0}}, carry_sign_c}) :
                        (i_alu_op[2:0] == ALU_OP_SLTU) ?    ({{DATA_WIDTH{1'h0}}, carry_unsigned_c}) :
                        (i_alu_op[2:0] == ALU_OP_XOR) ?     (value1_c ^ value2_c) :
                        (i_alu_op[2:0] == ALU_OP_SRL_SRA) ? (srl_sra_value_c) :
                        (i_alu_op[2:0] == ALU_OP_OR) ?      (value1_c | value2_c) :
                                                            (value1_c & value2_c); // ALU_OP_AND
  
  assign width_c = (i_read || i_write) ? ({SIGN, MEM_WIDTH_DWORD}) : (i_width);
  assign sign_c = width_c[2];
  
  assign o_carry = (sign_c) ? (carry_sign_c) : (carry_unsigned_c);
  assign o_zero = (sub_value_c == {DATA_WIDTH{1'h0}});
  
  assign o_rs1_data = value1_c;
  assign o_rs2_data = value3_c;
  
  assign o_alu_data = (i_width[1:0] == MEM_WIDTH_WORD) ? ({{32{alu_result_c[31]}}, alu_result_c[31:0]}) : (alu_result_c);
  
endmodule
