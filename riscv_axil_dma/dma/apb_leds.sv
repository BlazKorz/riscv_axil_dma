import common_cells_pkg::*;

module apb_leds #(
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
  
  output o_pready,
  output [APB_DATA_WIDTH - 1:0] o_prdata,
  output [15:0] o_leds
  );
  
  wire                        pready_en_c;
  wire                        pready_c;
  reg                         pready_r;
  
  wire                        prdata0_en_c;
  wire                        prdata1_en_c;
  reg  [APB_DATA_WIDTH - 1:0] prdata_c [2];
  reg  [APB_DATA_WIDTH - 1:0] prdata_r [2];
  
  assign pready_en_c = i_psel && i_penable && penable;
  assign pready_c = ~pready_r && pready_en_c;
 `RTL_REG_ASYNC (pclk, pnreset, pready_en_c, pready_c, pready_r, 1);
  
  assign prdata0_en_c = (i_paddr[0] == 'h0) && i_pwrite && i_psel && i_penable && penable;
  assign prdata_c[0] = i_pwdata;
 `RTL_REG_ASYNC (pclk, pnreset, prdata0_en_c, prdata_c[0], prdata_r[0], APB_DATA_WIDTH);
  
  assign prdata1_en_c = (i_paddr[0] == 'h1) && i_pwrite && i_psel && i_penable && penable;
  assign prdata_c[1] = i_pwdata;
 `RTL_REG_ASYNC (pclk, pnreset, prdata1_en_c, prdata_c[1], prdata_r[1], APB_DATA_WIDTH);
 
  assign o_pready = pready_r;
  assign o_prdata = (i_paddr[0] == 'h0) ? prdata_r[0] :
                                          prdata_r[1];
  assign o_leds = {prdata_r[1], prdata_r[0]};
  
  wire unused_ok = &{i_paddr[APB_ADDR_WIDTH - 1:1]};
  
endmodule
