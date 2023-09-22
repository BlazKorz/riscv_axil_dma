import riscv_pkg::*;

module riscv_mem_arbiter #(
  parameter DATA_WIDTH = 64,
  parameter STRB_WIDTH = DATA_WIDTH /8
  )(
  input [2:0] i_width,
 
  input [DATA_WIDTH - 1:0] i_rs2_data,
  input [DATA_WIDTH - 1:0] i_mem_rd_data,
  
  input [2:0] i_data_sel,
  
  output [DATA_WIDTH - 1:0] o_rs2_data,
  output [DATA_WIDTH - 1:0] o_mem_rd_data,
  output [STRB_WIDTH - 1:0] o_mem_wr_strb
  );
  
  reg [DATA_WIDTH - 1:0] rs2_data_c;
  reg [DATA_WIDTH - 1:0] mem_rd_data_c;
  reg [STRB_WIDTH - 1:0] mem_wr_strb_c;
  
  always_comb begin
    rs2_data_c <= {DATA_WIDTH{1'h0}};
    mem_wr_strb_c <= 8'b00000000;
    case (i_width[1:0])
      MEM_WIDTH_BYTE : begin
        case (i_data_sel)
          3'b000 : begin
            mem_wr_strb_c <= 8'b00000001;
            rs2_data_c[7:0] <= i_rs2_data[7:0];
            if (i_width[2]) begin
              mem_rd_data_c <= {56'b0, i_mem_rd_data[7:0]};
            end else begin
              mem_rd_data_c <= {{56{i_mem_rd_data[7]}}, i_mem_rd_data[7:0]};
            end
          end
          3'b001 : begin
            mem_wr_strb_c <= 8'b00000010;
            rs2_data_c[15:8] <= i_rs2_data[7:0];
            if (i_width[2]) begin
              mem_rd_data_c <= {56'b0, i_mem_rd_data[15:8]};
            end else begin       
              mem_rd_data_c <= {{56{i_mem_rd_data[15]}}, i_mem_rd_data[15:8]};
            end
          end
          3'b010 : begin
            mem_wr_strb_c <= 8'b00000100;
            rs2_data_c[23:16] <= i_rs2_data[7:0];
            if (i_width[2]) begin
              mem_rd_data_c <= {56'b0, i_mem_rd_data[23:16]};
            end else begin
              mem_rd_data_c <= {{56{i_mem_rd_data[23]}}, i_mem_rd_data[23:16]};
            end
          end
          3'b011 : begin
            mem_wr_strb_c <= 8'b00001000;
            rs2_data_c[31:24] <= i_rs2_data[7:0];
            if (i_width[2]) begin
              mem_rd_data_c <= {56'b0, i_mem_rd_data[31:24]};
            end else begin
              mem_rd_data_c <= {{56{i_mem_rd_data[31]}}, i_mem_rd_data[31:24]};
            end
          end
          3'b100 : begin
            mem_wr_strb_c <= 8'b00010000;
            rs2_data_c[39:32] <= i_rs2_data[7:0];
            if (i_width[2]) begin
              mem_rd_data_c <= {56'b0, i_mem_rd_data[39:32]};
            end else begin
              mem_rd_data_c <= {{56{i_mem_rd_data[39]}}, i_mem_rd_data[39:32]};
            end
          end
          3'b101 : begin
            mem_wr_strb_c <= 8'b00100000;
            rs2_data_c[47:40] <= i_rs2_data[7:0];
            if (i_width[2]) begin
              mem_rd_data_c <= {56'b0, i_mem_rd_data[47:40]};
            end else begin
              mem_rd_data_c <= {{56{i_mem_rd_data[47]}}, i_mem_rd_data[47:40]};
            end
          end
          3'b110 : begin
            mem_wr_strb_c <= 8'b01000000;
            rs2_data_c[55:48] <= i_rs2_data[7:0];
            if (i_width[2]) begin
              mem_rd_data_c <= {56'b0, i_mem_rd_data[55:48]}; 
            end else begin
              mem_rd_data_c <= {{56{i_mem_rd_data[55]}}, i_mem_rd_data[55:48]};
            end
          end
          3'b111 : begin
            mem_wr_strb_c <= 8'b10000000;
            rs2_data_c[63:56] <= i_rs2_data[7:0];
            if (i_width[2]) begin
              mem_rd_data_c <= {56'b0, i_mem_rd_data[63:56]};
            end else begin
              mem_rd_data_c <= {{56{i_mem_rd_data[63]}}, i_mem_rd_data[63:56]};
            end
          end
        endcase
      end
      MEM_WIDTH_HWORD : begin
        case (i_data_sel[2:1])
          2'b00 : begin
            mem_wr_strb_c <= 8'b00000011;
            rs2_data_c[15:0] <= i_rs2_data[15:0];
            if (i_width[2]) begin
              mem_rd_data_c <= {48'b0, i_mem_rd_data[15:0]};
            end else begin
              mem_rd_data_c <= {{48{i_mem_rd_data[15]}}, i_mem_rd_data[15:0]};
            end
          end
          2'b01 : begin
            mem_wr_strb_c <= 8'b00001100;
            rs2_data_c[31:16] <= i_rs2_data[15:0];
            if (i_width[2]) begin
              mem_rd_data_c <= {48'b0, i_mem_rd_data[31:16]};
            end else begin
              mem_rd_data_c <= {{48{i_mem_rd_data[31]}}, i_mem_rd_data[31:16]};
            end
          end
          2'b10 : begin
            mem_wr_strb_c <= 8'b00110000;
            rs2_data_c[47:32] <= i_rs2_data[15:0];
            if (i_width[2]) begin
              mem_rd_data_c <= {48'b0, i_mem_rd_data[47:32]};
            end else begin
              mem_rd_data_c <= {{48{i_mem_rd_data[47]}}, i_mem_rd_data[47:32]};
            end
          end
          2'b11 : begin
            mem_wr_strb_c <= 8'b11000000;
            rs2_data_c[63:48] <= i_rs2_data[15:0];
            if (i_width[2]) begin
              mem_rd_data_c <= {48'b0, i_mem_rd_data[63:48]};
            end else begin
              mem_rd_data_c <= {{48{i_mem_rd_data[63]}}, i_mem_rd_data[63:48]};
            end
          end
        endcase
      end
      MEM_WIDTH_WORD : begin
        case (i_data_sel[2])
          1'b0 : begin
            mem_wr_strb_c <= 8'b00001111;
            rs2_data_c[31:0] <= i_rs2_data[31:0];
            if (i_width[2]) begin
              mem_rd_data_c <= {32'b0, i_mem_rd_data[31:0]};
            end else begin
              mem_rd_data_c <= {{32{i_mem_rd_data[31]}}, i_mem_rd_data[31:0]};
            end
          end
          1'b1 : begin
            mem_wr_strb_c <= 8'b11110000;
            rs2_data_c[63:32] <= i_rs2_data[31:0];
            if (i_width[2]) begin
              mem_rd_data_c <= {32'b0, i_mem_rd_data[63:48]};
            end else begin
              mem_rd_data_c <= {{32{i_mem_rd_data[63]}}, i_mem_rd_data[63:32]};
            end
          end
        endcase
      end
      MEM_WIDTH_DWORD : begin
        mem_wr_strb_c <= 8'b11111111;
        rs2_data_c <= i_rs2_data;
        mem_rd_data_c <= i_mem_rd_data;
      end
    endcase
  end
  
  assign o_rs2_data = rs2_data_c;
  assign o_mem_rd_data = mem_rd_data_c;
  assign o_mem_wr_strb = mem_wr_strb_c;
  
endmodule
