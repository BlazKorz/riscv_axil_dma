package riscv_pkg;
      
    //General_Purpose_Registers
    parameter FRAME_POINTER     = 5'b01000;
    
    //Control_Unit
    parameter NON               = 1'b1;
    parameter SIGN              = 1'b0;
    parameter UNSIGNED          = 1'b1;
    parameter BRANCH_SRC_PC     = 1'b0;
    parameter BRANCH_SRC_R1     = 1'b1;
    parameter WB_SRC_ALU_RESULT = 1'b1;
    parameter WB_SRC_DATA_MEM   = 1'b0;
    parameter SUB_SRA           = 1'b1;
    parameter ADD_SRL           = 1'b0;
    
    //Branch
    parameter BRANCH_BEQ         = 2'b00;
    parameter BRANCH_BNE         = 2'b01;
    parameter BRANCH_BLT         = 2'b10;
    parameter BRANCH_BGE         = 2'b11;
    parameter BRANCH_PC_ACCEPTED = 1'b1;
    
    //Arithmetic_Logic_Unit 
    parameter ALU_OP_ADD_SUB     = 3'b000;
    parameter ALU_OP_SLL         = 3'b001;
    parameter ALU_OP_SLT         = 3'b010;
    parameter ALU_OP_SLTU        = 3'b011;
    parameter ALU_OP_XOR         = 3'b100;
    parameter ALU_OP_SRL_SRA     = 3'b101;
    parameter ALU_OP_OR          = 3'b110;
    parameter ALU_OP_AND         = 3'b111;
    
    //Data_Flow_Select 
    parameter ALU_SRC_R1_R2       = 3'b000;
    parameter ALU_SRC_R1_IMM      = 3'b001;
    parameter ALU_SRC_R1_FOUR     = 3'b010;
    parameter ALU_SRC_PC_R2       = 3'b011;
    parameter ALU_SRC_PC_IMM      = 3'b100; 
    parameter ALU_SRC_PC_FOUR     = 3'b101;
    parameter ALU_SRC_ZERO_R2     = 3'b110; 
    parameter ALU_SRC_ZERO_IMM    = 3'b111;
    
    //Control_And_Status_Register
    parameter CSR_OP_RW           = 2'b01;
    parameter CSR_OP_RS           = 2'b10;
    parameter CSR_OP_RC           = 2'b11;
    parameter MSIE  = 3; //machine software interrupt enable
    parameter MTIE  = 7; //machine timer interrupt enable
    parameter MEIE  = 11; //machine external interrupt enable
    parameter CSR_CYCLE = 12'h000; 
    parameter CSR_RDTIME = 12'h001; // UNUSED
    parameter CSR_RDINSTRET = 12'h002; // UNUSED
    parameter CSR_MTIME = 12'h003;
    parameter CSR_MTIMECMP = 12'h004; 
    parameter CSR_MIE = 12'h005;
    parameter CSR_MIEPC = 12'h006;
    parameter TIMER = 100000;
    
    parameter LINK_1 = 5'h1;
    parameter LINK_5 = 5'h5;
    //Immediate_Generation
    parameter IMM_I_TYPE       =   3'b000;
    parameter IMM_S_TYPE       =   3'b001;
    parameter IMM_U_TYPE       =   3'b010;
    parameter IMM_J_TYPE       =   3'b011;
    parameter IMM_B_TYPE       =   3'b100;

    //Memory
    parameter MEM_WIDTH_BYTE     =  2'b00;
    parameter MEM_WIDTH_HWORD    =  2'b01;
    parameter MEM_WIDTH_WORD     =  2'b10;
    parameter MEM_WIDTH_DWORD    =  2'b11;
    parameter LED                =  12'hA;

    //Control_Unit
    parameter LUI = 7'b0110111;
    parameter AUIPC = 7'b0010111;
    parameter JAL = 7'b1101111;
    parameter JALR = 7'b1100111;
    parameter BEQ_BNE_BLT_BGE_BLTU_BGEU = 7'b1100011;
    parameter LB_LH_LW_LBU_LHU_LWU_LD = 7'b0000011;
    parameter SB_SH_SW_SD = 7'b0100011;
    parameter ADDI_SLTI_SLTIU_XORI_ORI_ANDI_SLLI_SRLI_SRAI = 7'b0010011;
    parameter ADD_SUB_SLL_SLT_SLTU_XOR_SRL_SRA_OR_AND = 7'b0110011;
    parameter FENCE_FENCEI = 7'b0001111;
    parameter ECALL_EBREAK = 7'b1110011;
    parameter CSRRW_CSRRS_CSRRC_CSRRWI_CSRRSI_CSRRCI = 7'b1110011;
    parameter ADDIW_SLLIW_SRLIW_SRLIW_SRAIW_ADDW_SUBW_SLLW_SRLW_SRAW=  7'b0011011;

endpackage
