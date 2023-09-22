import common_cells_pkg::*;

module dma_axil_arbiter #(
  parameter APB_STR_CHA = 2,
  parameter ADDR_WIDTH = 16,
  parameter DATA_WIDTH = 64,
  parameter STRB_WIDTH = (DATA_WIDTH / 8)
  )(
  input aclk,
  input anreset,
  input aenable,
  
  input i_abort [APB_STR_CHA],
  
  output o_axil_wvalid,
  output [STRB_WIDTH - 1:0] o_axil_wstrb,
  output [DATA_WIDTH - 1:0] o_axil_wdata,
  output [ADDR_WIDTH - 1:0] o_axil_waddr,
  input i_axil_wready,
  
  output o_axil_rready,
  output [ADDR_WIDTH - 1:0] o_axil_raddr,
  input i_axil_rvalid,
  input [DATA_WIDTH - 1:0] i_axil_rdata,
  
  input i_axil_wvalid [APB_STR_CHA],
  input [STRB_WIDTH - 1:0] i_axil_wstrb [APB_STR_CHA],
  input [DATA_WIDTH - 1:0] i_axil_wdata [APB_STR_CHA],
  input [ADDR_WIDTH - 1:0] i_axil_waddr [APB_STR_CHA],
  output o_axil_wready [APB_STR_CHA],
  
  input i_axil_rready [APB_STR_CHA],
  input [ADDR_WIDTH - 1:0] i_axil_raddr [APB_STR_CHA],
  output o_axil_rvalid [APB_STR_CHA],
  output [DATA_WIDTH - 1:0] o_axil_rdata [APB_STR_CHA]
  );
  
  wire                                  abort_c;
  wire                                  abord_comp_c;
  
  wire                                  idle_wr;
  wire                                  ch_0_wr;
  wire                                  ch_1_wr;
  wire                                  aborting_wr;
  reg  [FSM_DMA_ARB_WR_ABORTING - 1:0]  dma_arb_wr_fsm_nxt_c;
  reg  [FSM_DMA_ARB_WR_ABORTING - 1:0]  dma_arb_wr_fsm_r;
  
  wire                                  idle_rd;
  wire                                  ch_0_rd;
  wire                                  ch_1_rd;
  wire                                  aborting_rd;
  reg  [FSM_DMA_ARB_RD_ABORTING - 1:0]  dma_arb_rd_fsm_nxt_c;
  reg  [FSM_DMA_ARB_RD_ABORTING - 1:0]  dma_arb_rd_fsm_r;
  
  wire                                  axil_wvalid_c;
  wire [STRB_WIDTH - 1:0]               axil_wstrb_c;
  wire [DATA_WIDTH - 1:0]               axil_wdata_c;
  wire [ADDR_WIDTH - 1:0]               axil_waddr_c;
  wire                                  axil_wready_c [APB_STR_CHA];
  wire                                  axil_rready_c;
  wire [ADDR_WIDTH - 1:0]               axil_raddr_c;
  wire                                  axil_rvalid_c [APB_STR_CHA];
  wire [DATA_WIDTH - 1:0]               axil_rdata_c [APB_STR_CHA];
  
  
  assign abort_c = i_abort[0] || i_abort[1];
  assign abord_comp_c = !abort_c;
  
  
  always_comb begin
    case (dma_arb_wr_fsm_r)
      FSM_DMA_ARB_WR_IDLE :
        dma_arb_wr_fsm_nxt_c = (abort_c) ?          FSM_DMA_ARB_WR_ABORTING :
                               (i_axil_wvalid[1]) ? FSM_DMA_ARB_WR_CH1 :
                               (i_axil_wvalid[0]) ? FSM_DMA_ARB_WR_CH0 :
                                                    FSM_DMA_ARB_WR_IDLE;
      FSM_DMA_ARB_WR_CH0 :
        dma_arb_wr_fsm_nxt_c = (abort_c) ?          FSM_DMA_ARB_WR_ABORTING :
                               (i_axil_wready) ?
                               (i_axil_wvalid[1]) ? FSM_DMA_ARB_WR_CH1 :
                                                    FSM_DMA_ARB_WR_IDLE :
                               (FSM_DMA_ARB_WR_CH0);
      FSM_DMA_ARB_WR_CH1 :
        dma_arb_wr_fsm_nxt_c = (abort_c) ?          FSM_DMA_ARB_WR_ABORTING :
                               (i_axil_wready) ?
                               (i_axil_wvalid[0]) ? FSM_DMA_ARB_WR_CH0 :
                                                    FSM_DMA_ARB_WR_IDLE :
                               (FSM_DMA_ARB_WR_CH1);
      FSM_DMA_ARB_WR_ABORTING :
        dma_arb_wr_fsm_nxt_c = (abord_comp_c) ?     FSM_DMA_ARB_WR_IDLE :
                                                    FSM_DMA_ARB_WR_ABORTING;
      default :
        dma_arb_wr_fsm_nxt_c = {DMA_ARB_WR_FSM_WIDTH{1'hx}};
    endcase
  end
 `RTL_REG_ASYNC (aclk, anreset, 1, dma_arb_wr_fsm_nxt_c, dma_arb_wr_fsm_r, DMA_ARB_WR_FSM_WIDTH);
  
  assign idle_wr = (dma_arb_wr_fsm_r == FSM_DMA_ARB_WR_IDLE);
  assign ch_0_wr = (dma_arb_wr_fsm_r == FSM_DMA_ARB_WR_CH0);
  assign ch_1_wr = (dma_arb_wr_fsm_r == FSM_DMA_ARB_WR_CH1);
  assign aborting_wr = (dma_arb_wr_fsm_r == FSM_DMA_ARB_WR_ABORTING);
  
  assign axil_wvalid_c    = (ch_0_wr) ? i_axil_wvalid[0] :
                                        i_axil_wvalid[1];
  
  assign axil_wstrb_c     = (ch_0_wr) ? i_axil_wstrb[0] :
                                        i_axil_wstrb[1];
  
  assign axil_wdata_c     = (ch_0_wr) ? i_axil_wdata[0] :
                                        i_axil_wdata[1];
  
  assign axil_waddr_c     = (ch_0_wr) ? i_axil_waddr[0] :
                                        i_axil_waddr[1];
  
  assign axil_wready_c[0] = (ch_0_wr) ? i_axil_wready :
                                        1'h0;
  
  assign axil_wready_c[1] = (ch_1_wr) ? i_axil_wready :
                                        1'h0;
  
  
  always_comb begin
    case (dma_arb_rd_fsm_r)
      FSM_DMA_ARB_RD_IDLE :
        dma_arb_rd_fsm_nxt_c = (abort_c) ?          FSM_DMA_ARB_RD_ABORTING :
                               (i_axil_rready[1]) ? FSM_DMA_ARB_RD_CH1 :
                               (i_axil_rready[0]) ? FSM_DMA_ARB_RD_CH0 :
                                                    FSM_DMA_ARB_RD_IDLE;
      FSM_DMA_ARB_RD_CH0 :
        dma_arb_rd_fsm_nxt_c = (abort_c) ?          FSM_DMA_ARB_RD_ABORTING :
                               (i_axil_rvalid) ?
                               (i_axil_rready[1]) ? FSM_DMA_ARB_RD_CH1 :
                                                    FSM_DMA_ARB_RD_IDLE :
                               (FSM_DMA_ARB_WR_CH0);
      FSM_DMA_ARB_RD_CH1 :
        dma_arb_rd_fsm_nxt_c = (abort_c) ?          FSM_DMA_ARB_RD_ABORTING :
                               (i_axil_rvalid) ?
                               (i_axil_rready[0]) ? FSM_DMA_ARB_RD_CH0 :
                                                    FSM_DMA_ARB_RD_IDLE :
                               (FSM_DMA_ARB_WR_CH1);
      FSM_DMA_ARB_RD_ABORTING :
        dma_arb_rd_fsm_nxt_c = (abord_comp_c) ?     FSM_DMA_ARB_RD_IDLE :
                                                    FSM_DMA_ARB_RD_ABORTING;
      default :
        dma_arb_rd_fsm_nxt_c = {DMA_ARB_RD_FSM_WIDTH{1'hx}};
    endcase
  end
 `RTL_REG_ASYNC (aclk, anreset, 1, dma_arb_rd_fsm_nxt_c, dma_arb_rd_fsm_r, DMA_ARB_RD_FSM_WIDTH);
  
  assign idle_rd = (dma_arb_rd_fsm_r == FSM_DMA_ARB_RD_IDLE);
  assign ch_0_rd = (dma_arb_rd_fsm_r == FSM_DMA_ARB_RD_CH0);
  assign ch_1_rd = (dma_arb_rd_fsm_r == FSM_DMA_ARB_RD_CH1);
  assign aborting_rd = (dma_arb_rd_fsm_r == FSM_DMA_ARB_RD_ABORTING);
  
  assign axil_rready_c    = (ch_0_rd) ? i_axil_rready[0] :
                                        i_axil_rready[1];
  
  assign axil_raddr_c     = (ch_0_rd) ? i_axil_raddr[0] :
                                        i_axil_raddr[1];
  
  assign axil_rvalid_c[0] = (ch_0_rd) ? i_axil_rvalid :
                                        1'h0;
  
  assign axil_rvalid_c[1] = (ch_1_rd) ? i_axil_rvalid :
                                        1'h0;
  
  assign axil_rdata_c[0]  = (ch_0_rd) ? i_axil_rdata :
                                       {DATA_WIDTH{1'b0}};
  
  assign axil_rdata_c[1]  = (ch_1_rd) ? i_axil_rdata :
                                       {DATA_WIDTH{1'b0}};
  
  
  assign o_axil_wvalid = axil_wvalid_c;
  assign o_axil_wstrb = axil_wstrb_c;
  assign o_axil_wdata = axil_wdata_c;
  assign o_axil_waddr = axil_waddr_c;
  assign o_axil_wready[0] = axil_wready_c[0];
  assign o_axil_wready[1] = axil_wready_c[1];
  
  assign o_axil_rready = axil_rready_c;
  assign o_axil_raddr = axil_raddr_c;
  assign o_axil_rvalid[0] = axil_rvalid_c[0];
  assign o_axil_rvalid[1] = axil_rvalid_c[1];
  assign o_axil_rdata[0] = axil_rdata_c[0];
  assign o_axil_rdata[1] = axil_rdata_c[1];
  
endmodule
