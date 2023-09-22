import riscv_pkg::*;

module riscv_id_control_unit #(
  parameter INSTR_WIDTH = 32
  )(
  input [INSTR_WIDTH - 1:0] i_instr,
  
  output [2:0] o_alu_op,
  output [2:0] o_alu_src,
  output [2:0] o_imm,
  output [2:0] o_width,
  output [1:0] o_branch_op,
  output [1:0] o_csr_op,   
  output o_pc_src,
  output o_jump,
  output o_branch,
  output o_add_sub_srl_sra,
  output o_rd_write,
  output o_read,
  output o_write,
  output o_csr_write,
  output o_csr_read,
  output o_csr_rs1_imm,
  output o_wb_src,
  output o_valid_instr
  );
  
  assign o_alu_op =          (i_instr[6:0] == LUI) ?                                                    (ALU_OP_ADD_SUB) :
                             (i_instr[6:0] == AUIPC) ?                                                  (ALU_OP_ADD_SUB) :
                             (i_instr[6:0] == JAL) ?                                                    (ALU_OP_ADD_SUB) :
                             (i_instr[6:0] == JALR) ?                                                   (ALU_OP_ADD_SUB) :
                             (i_instr[6:0] == BEQ_BNE_BLT_BGE_BLTU_BGEU) ?                              (ALU_OP_ADD_SUB) :
                             (i_instr[6:0] == LB_LH_LW_LBU_LHU_LWU_LD) ?                                (ALU_OP_ADD_SUB) :
                             (i_instr[6:0] == SB_SH_SW_SD) ?                                            (ALU_OP_ADD_SUB) :
                             (i_instr[6:0] == ADDI_SLTI_SLTIU_XORI_ORI_ANDI_SLLI_SRLI_SRAI) ?           ({i_instr[14], i_instr[13], i_instr[12]}) :
                             (i_instr[6:0] == ADD_SUB_SLL_SLT_SLTU_XOR_SRL_SRA_OR_AND) ?                ({i_instr[14], i_instr[13], i_instr[12]}) :
                             (i_instr[6:0] == ADDIW_SLLIW_SRLIW_SRLIW_SRAIW_ADDW_SUBW_SLLW_SRLW_SRAW) ? ({i_instr[14], i_instr[13], i_instr[12]}) :
                                                                                                        (3'h0);
  
  assign o_alu_src =         (i_instr[6:0] == LUI) ?                                                    (ALU_SRC_ZERO_IMM) :
                             (i_instr[6:0] == AUIPC) ?                                                  (ALU_SRC_PC_IMM) :
                             (i_instr[6:0] == JAL) ?                                                    (ALU_SRC_PC_FOUR) :
                             (i_instr[6:0] == JALR) ?                                                   (ALU_SRC_PC_FOUR) :
                             (i_instr[6:0] == BEQ_BNE_BLT_BGE_BLTU_BGEU) ?                              (ALU_SRC_R1_R2) :
                             (i_instr[6:0] == LB_LH_LW_LBU_LHU_LWU_LD) ?                                (ALU_SRC_R1_IMM) :
                             (i_instr[6:0] == SB_SH_SW_SD) ?                                            (ALU_SRC_R1_R2) :
                             (i_instr[6:0] == ADDI_SLTI_SLTIU_XORI_ORI_ANDI_SLLI_SRLI_SRAI) ?           (ALU_SRC_R1_IMM) :
                             (i_instr[6:0] == ADD_SUB_SLL_SLT_SLTU_XOR_SRL_SRA_OR_AND) ?                (ALU_SRC_R1_R2) :
                             (i_instr[6:0] == CSRRW_CSRRS_CSRRC_CSRRWI_CSRRSI_CSRRCI) ?                 (ALU_SRC_R1_IMM) :
                             (i_instr[6:0] == ADDIW_SLLIW_SRLIW_SRLIW_SRAIW_ADDW_SUBW_SLLW_SRLW_SRAW) ? (ALU_SRC_R1_IMM) :
                                                                                                        (3'h0);
  
  assign o_imm =             (i_instr[6:0] == LUI) ?                                                    (IMM_U_TYPE) :
                             (i_instr[6:0] == AUIPC) ?                                                  (IMM_U_TYPE) :
                             (i_instr[6:0] == JAL) ?                                                    (IMM_J_TYPE) :
                             (i_instr[6:0] == JALR) ?                                                   (IMM_I_TYPE) :
                             (i_instr[6:0] == BEQ_BNE_BLT_BGE_BLTU_BGEU) ?                              (IMM_B_TYPE) :
                             (i_instr[6:0] == LB_LH_LW_LBU_LHU_LWU_LD) ?                                (IMM_I_TYPE) :
                             (i_instr[6:0] == SB_SH_SW_SD) ?                                            (IMM_S_TYPE) :
                             (i_instr[6:0] == ADDI_SLTI_SLTIU_XORI_ORI_ANDI_SLLI_SRLI_SRAI) ?           (IMM_I_TYPE) :
                             (i_instr[6:0] == CSRRW_CSRRS_CSRRC_CSRRWI_CSRRSI_CSRRCI) ?                 (IMM_I_TYPE) :
                             (i_instr[6:0] == ADDIW_SLLIW_SRLIW_SRLIW_SRAIW_ADDW_SUBW_SLLW_SRLW_SRAW) ? (IMM_I_TYPE) :
                                                                                                        (3'h0);
  
  assign o_width =           (i_instr[6:0] == LUI) ?                                                    ({SIGN, MEM_WIDTH_DWORD}) :
                             (i_instr[6:0] == AUIPC) ?                                                  ({SIGN, MEM_WIDTH_DWORD}) :
                             (i_instr[6:0] == BEQ_BNE_BLT_BGE_BLTU_BGEU) ?                              ({i_instr[13], MEM_WIDTH_DWORD}) :
                             (i_instr[6:0] == LB_LH_LW_LBU_LHU_LWU_LD) ?                                ({i_instr[14], i_instr[13], i_instr[12]}) :
                             (i_instr[6:0] == SB_SH_SW_SD) ?                                            ({i_instr[14], i_instr[13], i_instr[12]}) :
                             (i_instr[6:0] == ADDI_SLTI_SLTIU_XORI_ORI_ANDI_SLLI_SRLI_SRAI) ?           ({SIGN, MEM_WIDTH_DWORD}) :
                             (i_instr[6:0] == ADD_SUB_SLL_SLT_SLTU_XOR_SRL_SRA_OR_AND) ?                ({SIGN, MEM_WIDTH_DWORD}) :
                             (i_instr[6:0] == ADDIW_SLLIW_SRLIW_SRLIW_SRAIW_ADDW_SUBW_SLLW_SRLW_SRAW) ? ({SIGN, MEM_WIDTH_WORD}) :
                                                                                                        (3'h0);
  
  assign o_branch_op =       (i_instr[6:0] == BEQ_BNE_BLT_BGE_BLTU_BGEU) ?                              ({i_instr[14], i_instr[12]}) : (2'h0);
  
  assign o_csr_op =          (i_instr[6:0] == CSRRW_CSRRS_CSRRC_CSRRWI_CSRRSI_CSRRCI) ?                 ({i_instr[13], i_instr[12]}) : (3'h0);
  
  assign o_pc_src =          (i_instr[6:0] == JAL) ?                                                    (BRANCH_SRC_PC) :
                             (i_instr[6:0] == JALR) ?                                                   (BRANCH_SRC_R1) :
                             (i_instr[6:0] == BEQ_BNE_BLT_BGE_BLTU_BGEU) ?                              (BRANCH_SRC_PC) :
                                                                                                        (1'h0);
  
  assign o_jump =            (i_instr[6:0] == JAL) ?                                                    (1'h1) :
                             (i_instr[6:0] == JALR) ?                                                   (1'h1) :
                                                                                                        (1'h0);
  
  assign o_branch =          (i_instr[6:0] == BEQ_BNE_BLT_BGE_BLTU_BGEU) ?                              (1'h1) : (1'h0);
  
  assign o_add_sub_srl_sra = (i_instr[6:0] == LUI) ?                                                    (ADD_SRL) :
                             (i_instr[6:0] == AUIPC) ?                                                  (ADD_SRL) :
                             (i_instr[6:0] == JAL) ?                                                    (ADD_SRL) :
                             (i_instr[6:0] == JALR) ?                                                   (ADD_SRL) :
                             (i_instr[6:0] == BEQ_BNE_BLT_BGE_BLTU_BGEU) ?                              (SUB_SRA) :
                             (i_instr[6:0] == LB_LH_LW_LBU_LHU_LWU_LD) ?                                (ADD_SRL) :
                             (i_instr[6:0] == SB_SH_SW_SD) ?                                            (ADD_SRL) :
                             (i_instr[6:0] == ADDI_SLTI_SLTIU_XORI_ORI_ANDI_SLLI_SRLI_SRAI) ?           
                             ({i_instr[14], i_instr[13], i_instr[12]} == 3'h0) ?                         ADD_SRL :
                                                                                                         i_instr[30] :
                             (i_instr[6:0] == ADD_SUB_SLL_SLT_SLTU_XOR_SRL_SRA_OR_AND) ?                (i_instr[30]) :
                             (i_instr[6:0] == ADDIW_SLLIW_SRLIW_SRLIW_SRAIW_ADDW_SUBW_SLLW_SRLW_SRAW) ? (i_instr[30]) :
                                                                                                        (1'h0);
  
  assign o_rd_write =        (i_instr[6:0] == LUI) ?                                                    (1'h1) :
                             (i_instr[6:0] == AUIPC) ?                                                  (1'h1) :
                             (i_instr[6:0] == JAL) ?                                                    (i_instr[11:7] != 5'h0) :
                             (i_instr[6:0] == JALR) ?                                                   (i_instr[11:7] != 5'h0) :
                             (i_instr[6:0] == LB_LH_LW_LBU_LHU_LWU_LD) ?                                (1'h1) :
                             (i_instr[6:0] == ADDI_SLTI_SLTIU_XORI_ORI_ANDI_SLLI_SRLI_SRAI) ?           (1'h1) :
                             (i_instr[6:0] == ADD_SUB_SLL_SLT_SLTU_XOR_SRL_SRA_OR_AND) ?                (1'h1) :
                             (i_instr[6:0] == CSRRW_CSRRS_CSRRC_CSRRWI_CSRRSI_CSRRCI) ?                 (|i_instr[11:7]) :
                             (i_instr[6:0] == ADDIW_SLLIW_SRLIW_SRLIW_SRAIW_ADDW_SUBW_SLLW_SRLW_SRAW) ? (1'h1) :
                                                                                                        (1'h0);
  
  assign o_read =            (i_instr[6:0] == LB_LH_LW_LBU_LHU_LWU_LD) ?                                (1'h1) : (1'h0);
  
  assign o_write =           (i_instr[6:0] == SB_SH_SW_SD) ?                                            (1'h1) : (1'h0);
  
  assign o_csr_write =       (i_instr[6:0] == CSRRW_CSRRS_CSRRC_CSRRWI_CSRRSI_CSRRCI) ?                 
                             (CSR_OP_RW  == {i_instr[13], i_instr[12]}) ?                                1'h1 :
                             (|i_instr[19:15]) ?                                                         1'h1 :
                                                                                                         1'h0 :
                             (1'h0);
  
  assign o_csr_read =        (i_instr[6:0] == CSRRW_CSRRS_CSRRC_CSRRWI_CSRRSI_CSRRCI) ?                 
                             (i_instr[13]) ?                                                             1'h1 :
                             (|i_instr[11:7]) ?                                                          1'h1 :
                                                                                                         1'h0 :
                             (1'h0);
  
  assign o_csr_rs1_imm =     (i_instr[6:0] == CSRRW_CSRRS_CSRRC_CSRRWI_CSRRSI_CSRRCI) ?                 (~i_instr[14]) : (1'h0);
  
  assign o_wb_src =          (i_instr[6:0] == LUI) ?                                                    (WB_SRC_ALU_RESULT) :
                             (i_instr[6:0] == AUIPC) ?                                                  (WB_SRC_ALU_RESULT) :
                             (i_instr[6:0] == JAL) ?                                                    (WB_SRC_ALU_RESULT) :
                             (i_instr[6:0] == JALR) ?                                                   (WB_SRC_ALU_RESULT) :
                             (i_instr[6:0] == LB_LH_LW_LBU_LHU_LWU_LD) ?                                (WB_SRC_DATA_MEM) :
                             (i_instr[6:0] == ADDI_SLTI_SLTIU_XORI_ORI_ANDI_SLLI_SRLI_SRAI) ?           (WB_SRC_ALU_RESULT) :
                             (i_instr[6:0] == ADD_SUB_SLL_SLT_SLTU_XOR_SRL_SRA_OR_AND) ?                (WB_SRC_ALU_RESULT) :
                             (i_instr[6:0] == CSRRW_CSRRS_CSRRC_CSRRWI_CSRRSI_CSRRCI) ?                 (WB_SRC_ALU_RESULT) :
                             (i_instr[6:0] == ADDIW_SLLIW_SRLIW_SRLIW_SRAIW_ADDW_SUBW_SLLW_SRLW_SRAW) ? (WB_SRC_ALU_RESULT) :
                                                                                                        (1'h0);
  
  assign o_valid_instr =     (i_instr[6:0] == LUI) ?                                                    (1'h1) :
                             (i_instr[6:0] == AUIPC) ?                                                  (1'h1) :
                             (i_instr[6:0] == JAL) ?                                                    (1'h1) :
                             (i_instr[6:0] == JALR) ?                                                   (1'h1) :
                             (i_instr[6:0] == BEQ_BNE_BLT_BGE_BLTU_BGEU) ?                              (1'h1) :
                             (i_instr[6:0] == LB_LH_LW_LBU_LHU_LWU_LD) ?                                (1'h1) :
                             (i_instr[6:0] == SB_SH_SW_SD) ?                                            (1'h1) :
                             (i_instr[6:0] == ADDI_SLTI_SLTIU_XORI_ORI_ANDI_SLLI_SRLI_SRAI) ?           (1'h1) :
                             (i_instr[6:0] == ADD_SUB_SLL_SLT_SLTU_XOR_SRL_SRA_OR_AND) ?                (1'h1) :
                             (i_instr[6:0] == CSRRW_CSRRS_CSRRC_CSRRWI_CSRRSI_CSRRCI) ?                 (1'h1) :
                             (i_instr[6:0] == ADDIW_SLLIW_SRLIW_SRLIW_SRAIW_ADDW_SUBW_SLLW_SRLW_SRAW) ? (1'h1) :
                                                                                                        (1'h0);
  
endmodule
