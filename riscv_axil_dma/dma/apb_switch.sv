import common_cells_pkg::*;

module apb_switch #(
  parameter APB_ADDR_WIDTH = 16,
  parameter APB_DATA_WIDTH = 16
  )(
  input pclk,
  input pnreset,
  input penable,
  
  input i_penable,
  input i_psel,
  input i_pwrite,
  input [APB_DATA_WIDTH - 1:0] i_pwdata,
  input [APB_ADDR_WIDTH - 1:0] i_paddr,
  
  input [7:0] i_switch,
  
  output o_pready,
  output [APB_DATA_WIDTH - 1:0] o_prdata
  );
  
  wire                        pready_en_c;
  wire                        pready_c;
  reg                         pready_r;
  
  wire                        prdata_en_c;
  reg  [APB_DATA_WIDTH - 1:0] prdata_c;
  reg  [APB_DATA_WIDTH - 1:0] prdata_r;
  
  assign pready_en_c = i_psel && i_penable && penable;
  assign pready_c = ~pready_r && pready_en_c;
 `RTL_REG_ASYNC (pclk, pnreset, pready_en_c, pready_c, pready_r, 1);
 
  assign prdata_en_c = penable;
  assign prdata_c = i_switch;
 `RTL_REG_ASYNC (pclk, pnreset, prdata_en_c, prdata_c, prdata_r, APB_DATA_WIDTH);
 
  assign o_pready = pready_r;
  assign o_prdata = prdata_r;
  
  wire unused_ok = &{i_pwdata, i_paddr, i_pwrite};
  
endmodule
