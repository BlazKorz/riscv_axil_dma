import common_cells_pkg::*;

module dma_desc_arbiter #(
  parameter APB_STR_CHA = 2
  )(
  input aclk,
  input anreset,
  input aenable,
  
  input i_abort [APB_STR_CHA],
    
  input [1:0] i_desc_ch_sel,
  input i_desc_rready,
  output o_desc_rd,

  output o_resp_wr,
  output [7:0] o_resp_desc_id,
  output [1:0] o_resp_ch_sel,
  input i_resp_wready,
  
  output o_desc_rready [APB_STR_CHA],
  input i_desc_rd [APB_STR_CHA],
  
  input i_resp_wr [APB_STR_CHA],
  input [7:0] i_resp_desc_id [APB_STR_CHA],
  output o_resp_wready [APB_STR_CHA]
  );
  
  wire                                  abort_c;
  wire                                  abord_comp_c;
  
  wire                                  idle_rsp;
  wire                                  ch_0_rsp;
  wire                                  ch_1_rsp;
  wire                                  aborting_rsp;
  reg  [FSM_DMA_ARB_RSP_ABORTING - 1:0] dma_arb_rsp_fsm_nxt_c;
  reg  [FSM_DMA_ARB_RSP_ABORTING - 1:0] dma_arb_rsp_fsm_r;
  
  wire [7:0]                            resp_desc_id_c;
  wire [1:0]                            resp_ch_sel_c;
  wire                                  resp_wr_c;
  wire                                  resp_wready_c [APB_STR_CHA];
  wire                                  desc_rd_c;
  wire                                  desc_rready_c [APB_STR_CHA];
  
  
  assign abort_c = i_abort[0] || i_abort[1];
  assign abord_comp_c = !abort_c;
  
  
  assign desc_rd_c = i_desc_rready && (i_desc_rd[0] || i_desc_rd[1]);
  
  assign desc_rready_c[0] = (i_desc_ch_sel[0] == 1'h0) ? i_desc_rready :
                                                         1'h0;
  
  assign desc_rready_c[1] = (i_desc_ch_sel[0] == 1'h1) ? i_desc_rready :
                                                         1'h0;
  
  
  always_comb begin
    case (dma_arb_rsp_fsm_r)
      FSM_DMA_ARB_RSP_IDLE :
        dma_arb_rsp_fsm_nxt_c = (abort_c) ?            FSM_DMA_ARB_RSP_ABORTING :
                                (i_resp_wr[1]) ?       FSM_DMA_ARB_RSP_CH1 :
                                (i_resp_wr[0]) ?       FSM_DMA_ARB_RSP_CH0 :
                                                       FSM_DMA_ARB_RSP_IDLE;
      FSM_DMA_ARB_RSP_CH0 :
        dma_arb_rsp_fsm_nxt_c = (abort_c) ?            FSM_DMA_ARB_RSP_ABORTING :
                                (i_resp_wready) ?
                                (i_resp_wr[1]) ?       FSM_DMA_ARB_RSP_CH1 :
                                                       FSM_DMA_ARB_RSP_IDLE :
                                (FSM_DMA_ARB_RSP_CH0);
      FSM_DMA_ARB_RSP_CH1 :
        dma_arb_rsp_fsm_nxt_c = (abort_c) ?            FSM_DMA_ARB_RSP_ABORTING :
                                (i_resp_wready) ?
                                (i_resp_wr[0]) ?       FSM_DMA_ARB_RSP_CH0 :
                                                       FSM_DMA_ARB_RSP_IDLE :
                                (FSM_DMA_ARB_RSP_CH1);
      FSM_DMA_ARB_RSP_ABORTING :
        dma_arb_rsp_fsm_nxt_c = (abord_comp_c) ?       FSM_DMA_ARB_RSP_IDLE :
                                                       FSM_DMA_ARB_RSP_ABORTING;
      default :
        dma_arb_rsp_fsm_nxt_c = {DMA_ARB_RD_FSM_WIDTH{1'hx}};
    endcase
  end
 `RTL_REG_ASYNC (aclk, anreset, 1, dma_arb_rsp_fsm_nxt_c, dma_arb_rsp_fsm_r, DMA_ARB_RD_FSM_WIDTH);
  
  assign idle_rsp = (dma_arb_rsp_fsm_r == FSM_DMA_ARB_RSP_IDLE);
  assign ch_0_rsp = (dma_arb_rsp_fsm_r == FSM_DMA_ARB_RSP_CH0);
  assign ch_1_rsp = (dma_arb_rsp_fsm_r == FSM_DMA_ARB_RSP_CH1);
  assign aborting_rsp = (dma_arb_rsp_fsm_r == FSM_DMA_ARB_RSP_ABORTING);
  
  assign resp_desc_id_c   = (ch_0_rsp) ? i_resp_desc_id[0] :
                                         i_resp_desc_id[1];
  
  assign resp_ch_sel_c    = (ch_0_rsp) ? 0 :
                                         1;
  
  assign resp_wr_c        = ch_1_rsp || ch_0_rsp;
  
  assign resp_wready_c[0] = (ch_0_rsp) ? i_resp_wready :
                                         1'h0;
  
  assign resp_wready_c[1] = (ch_1_rsp) ? i_resp_wready :
                                         1'h0;
  
  
  assign o_desc_rd = desc_rd_c;
  assign o_desc_rready[0] = desc_rready_c[0];
  assign o_desc_rready[1] = desc_rready_c[1];
  
  assign o_resp_desc_id = resp_desc_id_c;
  assign o_resp_ch_sel = resp_ch_sel_c;
  assign o_resp_wr = resp_wr_c;
  assign o_resp_wready[0] = resp_wready_c[0];
  assign o_resp_wready[1] = resp_wready_c[1];
  
  wire unused_ok = &{i_desc_ch_sel[1]};
  
endmodule
