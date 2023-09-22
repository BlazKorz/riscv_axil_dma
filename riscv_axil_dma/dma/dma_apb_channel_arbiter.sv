import common_cells_pkg::*;

module dma_apb_channel_arbiter #(
  parameter APB_SVL = 4,
  parameter ADDR_WIDTH = 16,
  parameter APB_ADDR_WIDTH = 16,
  parameter APB_DATA_WIDTH = 16,
  parameter DATA_WIDTH = 64,
  parameter STRB_WIDTH = (DATA_WIDTH / 8)
  )(
  input clk,
  input nreset,
  input enable,
  
  input i_abort,
  
  output o_axil_wvalid,
  output [STRB_WIDTH - 1:0] o_axil_wstrb,
  output [DATA_WIDTH - 1:0] o_axil_wdata,
  output [ADDR_WIDTH - 1:0] o_axil_waddr,
  input i_axil_wready,
  
  output o_axil_rready,
  output [ADDR_WIDTH - 1:0] o_axil_raddr,
  input i_axil_rvalid,
  input [DATA_WIDTH - 1:0] i_axil_rdata,
  
  output o_desc_rd,
  input i_desc_endian,
  input i_desc_write,
  input [7:0] i_desc_len,
  input [2:0] i_desc_size,
  input [1:0] i_desc_burst,
  input [3:0] i_desc_sel,
  input [7:0] i_desc_id,
  input [ADDR_WIDTH - 1:0] i_desc_dma_addr,
  input [ADDR_WIDTH - 1:0] i_desc_mem_addr,
  input i_desc_rready,
  
  output o_resp_wr,
  output [7:0] o_resp_desc_id,
  input i_resp_wready,
  
  input i_dma2apb_full, 
  input i_apb2dma_empty,
  input [APB_DATA_WIDTH - 1:0] i_apb_pdata,
  output o_dma2apb_wvalid,
  output o_apb2dma_rready,
  output o_apb_pwrite,
  output [$clog2(APB_SVL) - 1:0] o_apb_psel,
  output [APB_DATA_WIDTH - 1:0] o_apb_pdata,
  output [APB_ADDR_WIDTH - 1:0] o_apb_paddr
  );
    
  wire                               abord_comp_c;
  
  wire                               execute_c;
  wire                               idle;
  wire                               setup;
  wire                               access;
  wire                               response;
  wire                               aborting;
  reg  [DMA_CHANNEL_FSM_WIDTH - 1:0] dma_channel_fsm_nxt_c;
  reg  [DMA_CHANNEL_FSM_WIDTH - 1:0] dma_channel_fsm_r;
  
  wire                               access_cpl_c;
  wire                               response_cpl_c;
  
  wire                               desc_setup_en_c;
  wire                               endian_c;
  reg                                endian_r;
  wire                               apb_write_c;
  reg                                apb_write_r;
  wire [7:0]                         len_c;
  reg  [7:0]                         len_r;
  wire [2:0]                         size_c;
  reg  [2:0]                         size_r;
  wire [1:0]                         burst_c;
  reg  [1:0]                         burst_r;
  wire [3:0]                         apb_sel_c;
  reg  [3:0]                         apb_sel_r;
  wire [7:0]                         desc_id_c;
  reg  [7:0]                         desc_id_r;
  wire [ADDR_WIDTH - 1:0]            apb_addr_c;
  reg  [ADDR_WIDTH - 1:0]            apb_addr_r;
  wire [ADDR_WIDTH - 1:0]            axil_addr_c;
  reg  [ADDR_WIDTH - 1:0]            axil_addr_r;
  
  reg  [3:0]                         num_of_bytes_c;
  wire [3:0]                         num_of_tran_c;
  wire [1:0]                         num_of_tran_clog2;
  wire [APB_ADDR_WIDTH - 1: 0]       num_of_shifts_c;
  
  wire                               axil_rready_c;
  wire                               axil_wvalid_c;
  wire [STRB_WIDTH - 1:0]            axil_wstrb_c;
  wire [DATA_WIDTH - 1:0]            axil_rdata_offset_c;
  wire [APB_ADDR_WIDTH - 1:0]        axil_rd_wr_addr_c;
  
  wire                               dma_axil_hs_cnt_en_c;
  wire [AXIL_CNT_WIDTH - 1:0]        dma_axil_hs_cnt_c;
  reg  [AXIL_CNT_WIDTH - 1:0]        dma_axil_hs_cnt_r;
  wire                               dma_axil_hs_c;
  wire                               dma_axil_hs_cnt_overflow_c;
  
  wire                               dma_apb_wr_hs_cnt_en_c;
  wire [APB_CNT_WIDTH - 1:0]         dma_apb_wr_hs_cnt_c;
  reg  [APB_CNT_WIDTH - 1:0]         dma_apb_wr_hs_cnt_r;
  wire                               dma_apb_wr_hs_c;
  wire                               dma_apb_wr_hs_cnt_overflow_c;
  wire [APB_CNT_WIDTH - 1:0]         dma_apb_wr_hs_cnt_burst_boundary_c;
  
  wire                               dma_apb_rd_hs_cnt_en_c;
  wire [APB_CNT_WIDTH - 1:0]         dma_apb_rd_hs_cnt_c;
  reg  [APB_CNT_WIDTH - 1:0]         dma_apb_rd_hs_cnt_r;
  wire                               dma_apb_rd_hs_c;
  wire                               dma_apb_rd_hs_cnt_overflow_c;
  wire [APB_CNT_WIDTH - 1:0]         dma_apb_rd_hs_cnt_burst_boundary_c;
  
  wire                               dma2axil_valid_en_c;
  wire [DATA_WIDTH - 1:0]            dma2axil_data_c;
  reg  [DATA_WIDTH - 1:0]            dma2axil_data_r;
  wire                               dma2axil_valid_c;
  reg                                dma2axil_valid_r;
  wire                               dma2axil_full_c;
  
  wire                               dma2apb_valid_en_c;
  wire [DATA_WIDTH - 1:0]            dma2apb_data_c;
  reg  [DATA_WIDTH - 1:0]            dma2apb_data_r;
  wire                               dma2apb_valid_c;
  reg                                dma2apb_valid_r;
  wire                               dma2apb_empty_c;
  
  
  // FSM AXIL <==> CORE ==> DMA <==> APB
  assign abord_comp_c = !i_abort;
  
  assign execute_c = i_desc_rready;
  
  always_comb begin
    case (dma_channel_fsm_r)
      FSM_DMA_CHANNEL_IDLE :
        dma_channel_fsm_nxt_c = (i_abort) ?        FSM_DMA_CHANNEL_ABORTING :
                                (execute_c) ?      FSM_DMA_CHANNEL_SETUP :
                                                   FSM_DMA_CHANNEL_IDLE;
      FSM_DMA_CHANNEL_SETUP :
        dma_channel_fsm_nxt_c = (i_abort) ?        FSM_DMA_CHANNEL_ABORTING :
                                                   FSM_DMA_CHANNEL_ACCESS;
      FSM_DMA_CHANNEL_ACCESS :
        dma_channel_fsm_nxt_c = (i_abort) ?        FSM_DMA_CHANNEL_ABORTING :
                                (access_cpl_c) ?   FSM_DMA_CHANNEL_RESPONSE :
                                                   FSM_DMA_CHANNEL_ACCESS;
      FSM_DMA_CHANNEL_RESPONSE :
        dma_channel_fsm_nxt_c = (i_abort) ?        FSM_DMA_CHANNEL_ABORTING :
                                (response_cpl_c) ? FSM_DMA_CHANNEL_IDLE :
                                                   FSM_DMA_CHANNEL_RESPONSE;
      FSM_DMA_CHANNEL_ABORTING,
      FSM_DMA_CHANNEL_101,
      FSM_DMA_CHANNEL_110,
      FSM_DMA_CHANNEL_111 :
        dma_channel_fsm_nxt_c = (abord_comp_c) ?   FSM_DMA_CHANNEL_IDLE :
                                                   FSM_DMA_CHANNEL_ABORTING;
      default :
        dma_channel_fsm_nxt_c = {DMA_CHANNEL_FSM_WIDTH{1'hx}};
    endcase
  end
 `RTL_REG_ASYNC (clk, nreset, 1, dma_channel_fsm_nxt_c, dma_channel_fsm_r, DMA_CHANNEL_FSM_WIDTH);
  
  assign idle = (dma_channel_fsm_r == FSM_DMA_CHANNEL_IDLE);
  assign setup = (dma_channel_fsm_r == FSM_DMA_CHANNEL_SETUP);
  assign access = (dma_channel_fsm_r == FSM_DMA_CHANNEL_ACCESS);
  assign response = (dma_channel_fsm_r == FSM_DMA_CHANNEL_RESPONSE);
  assign aborting = (dma_channel_fsm_r == FSM_DMA_CHANNEL_ABORTING);
  
  assign access_cpl_c = (mem2dma_acs) ? dma_apb_wr_hs_cnt_overflow_c :
                                        dma_axil_hs_cnt_overflow_c;
  assign response_cpl_c = response && i_resp_wready;
  
  assign dma2mem_acs = access && ~apb_write_r;
  assign mem2dma_acs = access && apb_write_r;
  
  
  // CORE ==> DESCIPTOR ==> DMA
  assign desc_setup_en_c = i_desc_rready && idle && enable;
  
  assign endian_c = i_desc_endian;
 `RTL_REG_ASYNC (clk, nreset, desc_setup_en_c, endian_c, endian_r, 1);
  
  assign apb_write_c = i_desc_write;
 `RTL_REG_ASYNC (clk, nreset, desc_setup_en_c, apb_write_c, apb_write_r, 1);
  
  assign len_c = i_desc_len;
 `RTL_REG_ASYNC (clk, nreset, desc_setup_en_c, len_c, len_r, 8);
  
  assign size_c = i_desc_size;
 `RTL_REG_ASYNC (clk, nreset, desc_setup_en_c, size_c, size_r, 3);
  
  assign burst_c = i_desc_burst;
 `RTL_REG_ASYNC (clk, nreset, desc_setup_en_c, burst_c, burst_r, 2);
  
  assign apb_sel_c = i_desc_sel;
 `RTL_REG_ASYNC (clk, nreset, desc_setup_en_c, apb_sel_c, apb_sel_r, 4);
  
  assign desc_id_c = i_desc_id;
 `RTL_REG_ASYNC (clk, nreset, desc_setup_en_c, desc_id_c, desc_id_r, 7);
  
  assign apb_addr_c = i_desc_dma_addr;
 `RTL_REG_ASYNC (clk, nreset, desc_setup_en_c, apb_addr_c, apb_addr_r, APB_ADDR_WIDTH);
  
  assign axil_addr_c = i_desc_mem_addr;
 `RTL_REG_ASYNC (clk, nreset, desc_setup_en_c, axil_addr_c, axil_addr_r, APB_ADDR_WIDTH);
  
  
  // DESCIPTOR DECODE
  assign axil_rdata_offset_c = (size_r[1:0] == SIZE_1B) ? 7 :
                               (size_r[1:0] == SIZE_2B) ? 6 :
                               (size_r[1:0] == SIZE_4B) ? 4 :
                                                          0;
  assign axil_wstrb_c =        (size_r[1:0] == SIZE_1B) ? 1 :
                               (size_r[1:0] == SIZE_2B) ? 3 :
                               (size_r[1:0] == SIZE_4B) ? 15 :
                                                          255;
  assign num_of_bytes_c =      (size_r[1:0] == SIZE_1B) ? 1 :
                               (size_r[1:0] == SIZE_2B) ? 2 :
                               (size_r[1:0] == SIZE_4B) ? 4 :
                                                          6;
  
  assign num_of_tran_c = (num_of_bytes_c >= (APB_DATA_WIDTH/8)) ? (num_of_bytes_c / (APB_DATA_WIDTH/8)) : 'h1;
  assign num_of_tran_clog2 = clog2(num_of_tran_c);
  assign num_of_shifts_c = APB_CNT_WIDTH - num_of_tran_clog2;
  
  
  // DMA <== HANDSHAKE WR/RD ==> AXILITE
  assign axil_rready_c = mem2dma_acs && ~dma2apb_valid_r && ~dma_axil_hs_cnt_overflow_c;
  assign axil_wvalid_c = dma2mem_acs && dma2axil_valid_r && ~dma_axil_hs_cnt_overflow_c;
  
  assign dma_axil_hs_c = (mem2dma_acs) ? axil_rready_c && i_axil_rvalid :
                         (dma2mem_acs) ? axil_wvalid_c && i_axil_wready :
                                         1'h0;
  
  assign dma_axil_hs_cnt_en_c = (setup || access) && enable;
  assign dma_axil_hs_cnt_c = (setup) ?         {APB_CNT_WIDTH{1'h0}} :
                             (dma_axil_hs_c) ?  dma_axil_hs_cnt_r + 1 :
                                                dma_axil_hs_cnt_r;
 `RTL_REG_ASYNC (clk, nreset, dma_axil_hs_cnt_en_c, dma_axil_hs_cnt_c, dma_axil_hs_cnt_r, AXIL_CNT_WIDTH);
  
  assign dma_axil_hs_cnt_overflow_c = (dma_axil_hs_cnt_r == len_r);
  
  
  // DMA <== HANDSHAKE WR ==> APB
  assign dma_apb_wr_hs_c = ((mem2dma_acs && dma2apb_valid_r) || dma2mem_acs) && ~i_dma2apb_full && ~dma_apb_wr_hs_cnt_overflow_c;
  
  assign dma_apb_wr_hs_cnt_en_c = (setup || access) && enable;
  assign dma_apb_wr_hs_cnt_c = (setup) ?           'h1 :
                               (dma_apb_wr_hs_c) ?  dma_apb_wr_hs_cnt_r + 1 :
                                                    dma_apb_wr_hs_cnt_r;
 `RTL_REG_ASYNC (clk, nreset, dma_apb_wr_hs_cnt_en_c, dma_apb_wr_hs_cnt_c, dma_apb_wr_hs_cnt_r, APB_CNT_WIDTH);
  
  assign dma_apb_wr_hs_cnt_overflow_c = (dma_apb_wr_hs_cnt_r == ((len_r << num_of_tran_clog2) + 1));
  assign dma_apb_wr_hs_cnt_burst_boundary_c = dma_apb_wr_hs_cnt_r << num_of_shifts_c;
  
  
  // DMA <== HANDSHAKE RD ==> APB
  assign dma_apb_rd_hs_c = dma2mem_acs && ~dma2axil_valid_r && ~i_apb2dma_empty && ~dma_apb_rd_hs_cnt_overflow_c;
  
  assign dma_apb_rd_hs_cnt_en_c = (setup || access) && enable;
  assign dma_apb_rd_hs_cnt_c = (setup) ?           'h1 :
                               (dma_apb_rd_hs_c) ?  dma_apb_rd_hs_cnt_r + 1 :
                                                    dma_apb_rd_hs_cnt_r;
 `RTL_REG_ASYNC (clk, nreset, dma_apb_rd_hs_cnt_en_c, dma_apb_rd_hs_cnt_c, dma_apb_rd_hs_cnt_r, APB_CNT_WIDTH);
  
  assign dma_apb_rd_hs_cnt_overflow_c = (dma_apb_rd_hs_cnt_r == ((len_r << num_of_tran_clog2) + 1));
  assign dma_apb_rd_hs_cnt_burst_boundary_c = dma_apb_rd_hs_cnt_r << num_of_shifts_c;    
  
  
  // AXIL ==> DATA ==> APB
  assign dma2apb_valid_en_c = mem2dma_acs && enable;
  
  assign dma2apb_data_c = (endian_r) ? 
                          (dma_axil_hs_c) ?   i_axil_rdata :
                          (dma_apb_wr_hs_c) ? dma2apb_data_r >> (STRB_WIDTH * (APB_DATA_WIDTH/8)) :
                                              dma2apb_data_r :
                          (dma_axil_hs_c) ?   i_axil_rdata << (axil_rdata_offset_c << $clog2(STRB_WIDTH)):
                          (dma_apb_wr_hs_c) ? dma2apb_data_r << (STRB_WIDTH * (APB_DATA_WIDTH/8)) :
                                              dma2apb_data_r;
 `RTL_REG_ASYNC (clk, nreset, dma2apb_valid_en_c, dma2apb_data_c, dma2apb_data_r, DATA_WIDTH);
  
  assign dma2apb_valid_c = (dma_axil_hs_c) ?                      1'b1 :
                           (dma2apb_empty_c && dma_apb_wr_hs_c) ? 1'b0 :
                                                                  dma2apb_valid_r;
 `RTL_REG_ASYNC (clk, nreset, dma2apb_valid_en_c, dma2apb_valid_c, dma2apb_valid_r, 1);
  
  assign dma2apb_empty_c = (num_of_tran_c != 4'h1) ? (dma_apb_wr_hs_cnt_burst_boundary_c == 0) :
                                                     (dma_apb_wr_hs_cnt_r != 0);
  
  
  // AXIL <== DATA <== APB
  assign dma2axil_valid_en_c = dma2mem_acs && enable;
  
  assign dma2axil_data_c = (endian_r) ? 
                           (dma_apb_rd_hs_c) ? {i_apb_pdata, dma2axil_data_r[DATA_WIDTH - 1:APB_DATA_WIDTH]} :
                                                dma2axil_data_r :
                           (dma_apb_rd_hs_c) ? {dma2axil_data_r[DATA_WIDTH - APB_DATA_WIDTH - 1:0], i_apb_pdata} :
                                                dma2axil_data_r;
 `RTL_REG_ASYNC (clk, nreset, dma2axil_valid_en_c, dma2axil_data_c[DATA_WIDTH - 1:0], dma2axil_data_r, DATA_WIDTH);
  
  assign dma2axil_valid_c = (dma2axil_full_c && dma_apb_rd_hs_c) ? 1'b1 :
                            (dma_axil_hs_c) ?                      1'b0 :
                                                                   dma2axil_valid_r;
 `RTL_REG_ASYNC (clk, nreset, dma2axil_valid_en_c, dma2axil_valid_c, dma2axil_valid_r, 1);
  
  assign dma2axil_full_c = (num_of_tran_c != 4'h1) ? (dma_apb_rd_hs_cnt_burst_boundary_c == 0) :
                                                     (dma_apb_rd_hs_cnt_r != 0);
  
  
  assign axil_rd_wr_addr_c = axil_addr_r + ((dma_axil_hs_cnt_r) << $clog2(STRB_WIDTH));
  
  assign o_axil_wvalid = axil_wvalid_c;
  assign o_axil_wstrb = axil_wstrb_c;
  assign o_axil_wdata = (endian_r) ? dma2axil_data_r >> (axil_rdata_offset_c << $clog2(STRB_WIDTH)) :
                                     dma2axil_data_r;
  assign o_axil_waddr = axil_rd_wr_addr_c;
  
  assign o_axil_rready = axil_rready_c;
  assign o_axil_raddr = axil_rd_wr_addr_c;
  
  assign o_desc_rd = i_desc_rready && idle;
  assign o_resp_wr = response;
  assign o_resp_desc_id = desc_id_r;
  
  assign o_dma2apb_wvalid = dma_apb_wr_hs_c;
  assign o_apb2dma_rready = dma_apb_rd_hs_c;
  
  assign o_apb_pwrite = apb_write_r;
  assign o_apb_psel = apb_sel_r[$clog2(APB_SVL) - 1:0];
  assign o_apb_pdata = (endian_r) ? dma2apb_data_r[APB_DATA_WIDTH - 1:0] :
                                    dma2apb_data_r[DATA_WIDTH - 1:DATA_WIDTH - APB_DATA_WIDTH];
  assign o_apb_paddr = (burst_r[0] == INCR) ? apb_addr_r + (dma_apb_wr_hs_cnt_r - 1) : apb_addr_r;
  
  wire unused_ok = &{size_r[2], burst_r[1]};
  
endmodule
