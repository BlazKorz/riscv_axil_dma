import common_cells_pkg::*;

module dma_apb_arbiter #(
  parameter APB_SVL = 4,
  parameter APB_ADDR_WIDTH = 16,
  parameter APB_DATA_WIDTH = 16
  )(
  input pclk,
  input pnreset,
  input penable,
  
  input i_abort,
  input i_pready,
  input i_wr_full,
  input i_rd_empty,
  input	i_write,
  input	[$clog2(APB_SVL) - 1:0] i_sel,
  
  input [APB_DATA_WIDTH - 1:0] i_data,
  
  input [APB_ADDR_WIDTH - 1:0] i_addr,
  
  output o_penable,
  output o_pwrite,
  output o_wr_valid,
  output o_rd_valid,
  output [$clog2(APB_SVL) - 1:0] o_psel,
  
  output [APB_DATA_WIDTH - 1:0] o_pwdata,
  
  output [APB_ADDR_WIDTH - 1:0]	o_paddr
  );
  
  wire                           abord_comp_c;
  
  wire                           execute_c[2];
  reg                            execute_r;
  
  wire                           idle;
  wire                           setup;
  wire                           access;
  wire                           aborting;
  reg  [DMA_APB_FSM_WIDTH - 1:0] dma_apb_fsm_nxt_c;
  reg  [DMA_APB_FSM_WIDTH - 1:0] dma_apb_fsm_r;
  
  wire                           apb_en_c;
  wire                           pwrite_c;
  reg                            pwrite_r;
  wire [$clog2(APB_SVL) - 1:0]   psel_c;
  reg  [$clog2(APB_SVL) - 1:0]   psel_r;
  wire [APB_DATA_WIDTH - 1:0]    wdata_c;
  reg  [APB_DATA_WIDTH - 1:0]    wdata_r;
  wire [APB_ADDR_WIDTH - 1:0]    paddr_c;
  reg  [APB_ADDR_WIDTH - 1:0]    paddr_r;
  
  assign abord_comp_c = !i_abort;
  
  assign execute_c[0] = (i_rd_empty) ?            1'h0 :
                        (i_wr_full && ~i_write) ? 1'h0 :
                                                  1'h1;
 `RTL_REG_ASYNC (pclk, pnreset, penable, execute_c[0], execute_r, 1);
 
  assign execute_c[1] = execute_r && ~i_rd_empty;

  always_comb begin
    case (dma_apb_fsm_r)
      FSM_DMA_APB_IDLE :
        dma_apb_fsm_nxt_c = (i_abort) ?       FSM_DMA_APB_ABORTING :
                            (execute_c[1]) ?  FSM_DMA_APB_SETUP :
                                              FSM_DMA_APB_IDLE;
      FSM_DMA_APB_SETUP :
        dma_apb_fsm_nxt_c = (i_abort) ?       FSM_DMA_APB_ABORTING :
                                              FSM_DMA_APB_ACCESS;
      FSM_DMA_APB_ACCESS :
        dma_apb_fsm_nxt_c = (i_abort) ?       FSM_DMA_APB_ABORTING :
                            (i_pready) ?
                            (execute_c[1]) ?  FSM_DMA_APB_SETUP :
                                              FSM_DMA_APB_IDLE :
                            (FSM_DMA_APB_ACCESS);
      FSM_DMA_APB_ABORTING :
        dma_apb_fsm_nxt_c = (abord_comp_c) ? FSM_DMA_APB_IDLE :
                                         FSM_DMA_APB_ABORTING;
      default :
        dma_apb_fsm_nxt_c = {DMA_APB_FSM_WIDTH{1'hx}};
    endcase
  end
 `RTL_REG_ASYNC (pclk, pnreset, 1, dma_apb_fsm_nxt_c, dma_apb_fsm_r, DMA_APB_FSM_WIDTH);
  
  assign idle = (dma_apb_fsm_r == FSM_DMA_APB_IDLE);
  assign setup = (dma_apb_fsm_r == FSM_DMA_APB_SETUP);
  assign access = (dma_apb_fsm_r == FSM_DMA_APB_ACCESS);
  assign aborting = (dma_apb_fsm_r == FSM_DMA_APB_ABORTING);
  
  assign apb_en_c = execute_c[1] && (idle || (access && i_pready)) && penable;
  
  assign pwrite_c = i_write;
 `RTL_REG_ASYNC (pclk, pnreset, apb_en_c, pwrite_c, pwrite_r, 1);
  
  assign psel_c = i_sel;
 `RTL_REG_ASYNC (pclk, pnreset, apb_en_c, psel_c, psel_r, $clog2(APB_SVL));
  
  assign wdata_c = i_data;
 `RTL_REG_ASYNC (pclk, pnreset, apb_en_c, wdata_c, wdata_r, APB_DATA_WIDTH);
  
  assign paddr_c = i_addr;
 `RTL_REG_ASYNC (pclk, pnreset, apb_en_c, paddr_c, paddr_r, APB_ADDR_WIDTH);
  
  assign o_penable = access;
  assign o_pwrite = pwrite_r;
  assign o_wr_valid = i_pready && ~pwrite_r;
  assign o_rd_valid = apb_en_c;
  assign o_psel = psel_r;
  assign o_pwdata = wdata_r;
  assign o_paddr = paddr_r;
  
endmodule
