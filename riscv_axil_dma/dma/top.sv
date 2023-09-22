module top # (
  parameter         S_COUNT = 2,
  parameter         M_COUNT = 1,
  parameter         APB_STR_CHA = 2,
  parameter integer APB_SVL [APB_STR_CHA] = {2, 2},
  parameter         ADDR_WIDTH = 16,
  parameter         APB_ADDR_WIDTH = 16,
  parameter integer APB_FIFO_DMA2APB_ADDR_WIDTH [APB_STR_CHA] = {5, 5},
  parameter integer APB_FIFO_APB2DMA_ADDR_WIDTH [APB_STR_CHA] = {4, 4},
  parameter integer APB_DATA_WIDTH [APB_STR_CHA] = {16, 8},
  parameter         DATA_WIDTH = 64,
  parameter         INSTR_WIDTH = 32,
  parameter         STRB_WIDTH = (DATA_WIDTH / 8)
  )(
  input aclk,
  input pclk [APB_STR_CHA],
  input anreset,
  input pnreset [APB_STR_CHA],
  input aenable,
  input penable [APB_STR_CHA],
  
  input [7:0] i_switch,
  
  output [15:0] o_leds
  );
  
  wire                           apb_slave__pready_0 [APB_SVL[0]];
  wire                           apb_slave__pready_1 [APB_SVL[1]];
  wire [APB_DATA_WIDTH[0] - 1:0] apb_slave__prdata_0 [APB_SVL[0]];
  wire [APB_DATA_WIDTH[1] - 1:0] apb_slave__prdata_1 [APB_SVL[1]];
  
  wire                           riscv_prog_mem__valid;
  wire [INSTR_WIDTH - 1:0]       riscv_prog_mem__instr;
  
  wire                           riscv_top__read_instr;
  wire [ADDR_WIDTH - 1:0]        riscv_top__pc;
  wire                           riscv_top__desc_endian;
  wire                           riscv_top__desc_write;
  wire [1:0]                     riscv_top__desc_ch_sel;
  wire [7:0]                     riscv_top__desc_len;
  wire [2:0]                     riscv_top__desc_size;
  wire [1:0]                     riscv_top__desc_burst;
  wire [3:0]                     riscv_top__desc_sel;
  wire [7:0]                     riscv_top__desc_id;
  wire [ADDR_WIDTH - 1:0]        riscv_top__desc_dma_addr;
  wire [ADDR_WIDTH - 1:0]        riscv_top__desc_mem_addr;
  wire                           riscv_top__resp_rd;
  wire [ADDR_WIDTH - 1:0]        riscv_top__awaddr;
  wire [2:0]                     riscv_top__awprot;
  wire                           riscv_top__awvalid;
  wire [DATA_WIDTH - 1:0]        riscv_top__wdata;
  wire [STRB_WIDTH - 1:0]        riscv_top__wstrb;
  wire                           riscv_top__wvalid;
  wire                           riscv_top__bready;
  wire [ADDR_WIDTH - 1:0]        riscv_top__araddr;
  wire [2:0]                     riscv_top__arprot;
  wire                           riscv_top__arvalid;
  wire                           riscv_top__rready;
  
  wire                           dma_risc_bridge__desc_endian;
  wire                           dma_risc_bridge__desc_write;
  wire [1:0]                     dma_risc_bridge__desc_ch_sel;
  wire [7:0]                     dma_risc_bridge__desc_len;
  wire [2:0]                     dma_risc_bridge__desc_size;
  wire [1:0]                     dma_risc_bridge__desc_burst;
  wire [3:0]                     dma_risc_bridge__desc_sel;
  wire [7:0]                     dma_risc_bridge__desc_id;
  wire [ADDR_WIDTH - 1:0]        dma_risc_bridge__desc_dma_addr;
  wire [ADDR_WIDTH - 1:0]        dma_risc_bridge__desc_mem_addr;
  wire                           dma_risc_bridge__desc_rready;
  wire                           dma_risc_bridge__desc_wready;
  wire [7:0]                     dma_risc_bridge__tran_id;
  wire [1:0]                     dma_risc_bridge__tran_ch;
  wire                           dma_risc_bridge__trid_rready;
  wire                           dma_risc_bridge__resp_wready;
  
  wire [1:0]                     axil_interconnect__awready;
  wire [1:0]                     axil_interconnect__wready;
  wire [3:0]                     axil_interconnect__bresp;
  wire [1:0]                     axil_interconnect__bvalid;
  wire [1:0]                     axil_interconnect__arready;
  wire [(DATA_WIDTH * 2) - 1:0]  axil_interconnect__rdata;
  wire [3:0]                     axil_interconnect__rresp;
  wire [1:0]                     axil_interconnect__rvalid;
  
  wire [ADDR_WIDTH - 1:0]        axil_ram__awaddr;
  wire [2:0]                     axil_ram__awprot;
  wire                           axil_ram__awvalid;
  wire                           axil_ram__awready;
  wire [DATA_WIDTH - 1:0]        axil_ram__wdata;
  wire [STRB_WIDTH - 1:0]        axil_ram__wstrb;
  wire                           axil_ram__wvalid;
  wire                           axil_ram__wready;
  wire [1:0]                     axil_ram__bresp;
  wire                           axil_ram__bvalid;
  wire                           axil_ram__bready;
  wire [ADDR_WIDTH - 1:0]        axil_ram__araddr;
  wire [2:0]                     axil_ram__arprot;
  wire                           axil_ram__arvalid;
  wire                           axil_ram__arready;
  wire [DATA_WIDTH - 1:0]        axil_ram__rdata;
  wire [1:0]                     axil_ram__rresp;
  wire                           axil_ram__rvalid;
  wire                           axil_ram__rready;
  
  wire                           axil_dma__desc_rd;
  wire                           axil_dma__resp_wr;
  wire [7:0]                     axil_dma__resp_desc_id;
  wire [1:0]                     axil_dma__resp_ch_sel;
  wire [ADDR_WIDTH - 1:0]        axil_dma__awaddr;
  wire [2:0]                     axil_dma__awprot;
  wire                           axil_dma__awvalid;
  wire [DATA_WIDTH - 1:0]        axil_dma__wdata;
  wire [STRB_WIDTH - 1:0]        axil_dma__wstrb;
  wire                           axil_dma__wvalid;
  wire                           axil_dma__bready;
  wire [ADDR_WIDTH - 1:0]        axil_dma__araddr;
  wire [2:0]                     axil_dma__arprot;
  wire                           axil_dma__arvalid;
  wire                           axil_dma__rready;
  wire                           axil_dma__penable [APB_STR_CHA];
  wire                           axil_dma__psel_0 [APB_SVL[0]];
  wire                           axil_dma__psel_1 [APB_SVL[1]];
  wire                           axil_dma__pwrite [APB_STR_CHA];
  wire [APB_DATA_WIDTH[0] - 1:0] axil_dma__pwdata_0;
  wire [APB_DATA_WIDTH[1] - 1:0] axil_dma__pwdata_1;
  wire [APB_ADDR_WIDTH - 1:0]    axil_dma__paddr [APB_STR_CHA];

  localparam [APB_DATA_WIDTH[0] - 1:0] APB_MEM_IMAGE_CH0[2][16] = '{{16'h4433, 16'h3413, 16'h9F42, 16'h4f11, 16'heafd, 16'hd50a, 16'hbbaa, 16'habef,
                                                                     16'h7384, 16'h4133, 16'hae00, 16'haad1, 16'h9F42, 16'hd11a, 16'h1dae, 16'h11ea},
                                                                    {16'h8c22, 16'h1144, 16'hfe01, 16'hcbb3, 16'h9d2b, 16'hdd11, 16'hcc0d, 16'hecce,
                                                                     16'hd341, 16'h3ab3, 16'h01cb, 16'hffcc, 16'he01d, 16'hcc00, 16'hc3ca, 16'ha22f}};
  generate
    for (genvar id = 0; id < APB_SVL[0]; id = id + 1) begin : apb_slave_ch0
      apb_slave #(
        .APB_ADDR_WIDTH (APB_ADDR_WIDTH),
        .APB_DATA_WIDTH (APB_DATA_WIDTH[0]),
        .IMAGE_DEPTH    (16),
        .APB_MEM_IMAGE  (APB_MEM_IMAGE_CH0[id])
        ) apb_slave_ch0 (
          .pclk      (pclk[0]),
          .pnreset   (pnreset[0]),
          .penable   (penable[0]),
          .i_penable (axil_dma__penable[0]),
          .i_psel    (axil_dma__psel_0[id]),
          .i_pwrite  (axil_dma__pwrite[0]),
          .i_pwdata  (axil_dma__pwdata_0),
          .i_paddr   (axil_dma__paddr[0]),
          .o_pready  (apb_slave__pready_0[id]),
          .o_prdata  (apb_slave__prdata_0[id])
        );
    end
  endgenerate
    
  apb_switch #(
    .APB_ADDR_WIDTH (APB_ADDR_WIDTH),
    .APB_DATA_WIDTH (APB_DATA_WIDTH[1])
    ) apb_switch (
      .pclk            (pclk[1]),
      .pnreset         (pnreset[1]),
      .penable         (penable[1]),
      .i_penable       (axil_dma__penable[1]),
      .i_psel          (axil_dma__psel_1[1]),
      .i_pwrite        (axil_dma__pwrite[1]),
      .i_pwdata        (axil_dma__pwdata_1),
      .i_paddr         (axil_dma__paddr[1]),
      .i_switch        (i_switch),
      .o_pready        (apb_slave__pready_1[1]),
      .o_prdata        (apb_slave__prdata_1[1])
    );
  
  apb_leds #(
    .APB_ADDR_WIDTH (APB_ADDR_WIDTH),
    .APB_DATA_WIDTH (APB_DATA_WIDTH[1])
    ) apb_leds (
      .pclk            (pclk[1]),
      .pnreset         (pnreset[1]),
      .penable         (penable[1]),
      .i_penable       (axil_dma__penable[1]),
      .i_psel          (axil_dma__psel_1[0]),
      .i_pwrite        (axil_dma__pwrite[1]),
      .i_pwdata        (axil_dma__pwdata_1),
      .i_paddr         (axil_dma__paddr[1]),
      .o_pready        (apb_slave__pready_1[0]),
      .o_prdata        (apb_slave__prdata_1[0]),
      .o_leds          (o_leds)
    );
  
  riscv_prog_mem #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .INSTR_WIDTH(INSTR_WIDTH)
    ) riscv_prog_mem (
      .clk             (aclk),
      .nreset          (anreset),
      .enable          (aenable),
      .i_read          (riscv_top__read_instr),
      .i_pc            (riscv_top__pc),
      .o_valid         (riscv_prog_mem__valid),
      .o_instr         (riscv_prog_mem__instr)
    );
  
  assign instr = riscv_prog_mem__instr;
  assign pc = riscv_top__pc;
  
  riscv_top #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .INSTR_WIDTH(INSTR_WIDTH)
    ) riscv_top (      
      .clk             (aclk),
      .nreset          (anreset),
      .enable          (aenable),      
      .i_instr_valid   (riscv_prog_mem__valid),
      .i_instr         (riscv_prog_mem__instr),
      .o_read_instr    (riscv_top__read_instr),
      .o_busy          (o_busy),
      .o_pc            (riscv_top__pc),
      .o_desc_wr       (riscv_top__desc_wr),
      .o_desc_endian   (riscv_top__desc_endian),
      .o_desc_write    (riscv_top__desc_write),
      .o_desc_ch_sel   (riscv_top__desc_ch_sel),
      .o_desc_len      (riscv_top__desc_len),
      .o_desc_size     (riscv_top__desc_size),
      .o_desc_burst    (riscv_top__desc_burst),
      .o_desc_sel      (riscv_top__desc_sel),
      .o_desc_id       (riscv_top__desc_id),
      .o_desc_dma_addr (riscv_top__desc_dma_addr),
      .o_desc_mem_addr (riscv_top__desc_mem_addr),
      .i_desc_wready   (dma_risc_bridge__desc_wready),
      .o_resp_rd       (riscv_top__resp_rd),
      .i_resp_desc_id  (dma_risc_bridge__resp_desc_id),
      .i_resp_ch_sel   (dma_risc_bridge__resp_ch_sel),
      .i_resp_rready   (dma_risc_bridge__resp_rready),
      .o_awaddr        (riscv_top__awaddr),
      .o_awprot        (riscv_top__awprot),
      .o_awvalid       (riscv_top__awvalid),
      .i_awready       (axil_interconnect__awready[1]),
      .o_wdata         (riscv_top__wdata),
      .o_wstrb         (riscv_top__wstrb),
      .o_wvalid        (riscv_top__wvalid),
      .i_wready        (axil_interconnect__wready[1]),
      .i_bresp         (axil_interconnect__bresp[3:2]),
      .i_bvalid        (axil_interconnect__bvalid[1]),
      .o_bready        (riscv_top__bready),
      .o_araddr        (riscv_top__araddr),
      .o_arprot        (riscv_top__arprot),
      .o_arvalid       (riscv_top__arvalid),
      .i_arready       (axil_interconnect__arready[1]),
      .i_rdata         (axil_interconnect__rdata[(DATA_WIDTH * 2) - 1:DATA_WIDTH]),
      .i_rresp         (axil_interconnect__rresp[3:2]),
      .i_rvalid        (axil_interconnect__rvalid[1]),
      .o_rready        (riscv_top__rready)
    );
  
  bridge_risc_dma #(
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH)
    ) bridge_risc_dma (
      .risc_clk        (aclk),
      .risc_nreset     (anreset),
      .risc_enable     (aenable),
      .dma_clk         (aclk),
      .dma_nreset      (anreset),
      .dma_enable      (aenable),
      .i_desc_wr       (riscv_top__desc_wr),
      .i_desc_endian   (riscv_top__desc_endian),
      .i_desc_write    (riscv_top__desc_write),
      .i_desc_ch_sel   (riscv_top__desc_ch_sel),
      .i_desc_len      (riscv_top__desc_len),
      .i_desc_size     (riscv_top__desc_size),
      .i_desc_burst    (riscv_top__desc_burst),
      .i_desc_sel      (riscv_top__desc_sel),
      .i_desc_id       (riscv_top__desc_id),
      .i_desc_dma_addr (riscv_top__desc_dma_addr),
      .i_desc_mem_addr (riscv_top__desc_mem_addr),
      .o_desc_wready   (dma_risc_bridge__desc_wready),
      .i_resp_wr       (axil_dma__resp_wr),
      .i_resp_desc_id  (axil_dma__resp_desc_id),
      .i_resp_ch_sel   (axil_dma__resp_ch_sel),
      .o_resp_wready   (dma_risc_bridge__resp_wready),
      .i_desc_rd       (axil_dma__desc_rd),
      .o_desc_endian   (dma_risc_bridge__desc_endian),
      .o_desc_write    (dma_risc_bridge__desc_write),
      .o_desc_ch_sel   (dma_risc_bridge__desc_ch_sel),
      .o_desc_len      (dma_risc_bridge__desc_len),
      .o_desc_size     (dma_risc_bridge__desc_size),
      .o_desc_burst    (dma_risc_bridge__desc_burst),
      .o_desc_sel      (dma_risc_bridge__desc_sel),
      .o_desc_id       (dma_risc_bridge__desc_id),
      .o_desc_dma_addr (dma_risc_bridge__desc_dma_addr),
      .o_desc_mem_addr (dma_risc_bridge__desc_mem_addr),
      .o_desc_rready   (dma_risc_bridge__desc_rready),
      .i_resp_rd       (riscv_top__resp_rd),
      .o_resp_desc_id  (dma_risc_bridge__resp_desc_id),
      .o_resp_ch_sel   (dma_risc_bridge__resp_ch_sel),
      .o_resp_rready   (dma_risc_bridge__resp_rready)
    );
  
  axil_dma # (
    .APB_STR_CHA                 (APB_STR_CHA),
    .APB_SVL                     (APB_SVL),
    .ADDR_WIDTH                  (ADDR_WIDTH),
    .APB_ADDR_WIDTH              (APB_ADDR_WIDTH),
    .APB_FIFO_DMA2APB_ADDR_WIDTH (APB_FIFO_DMA2APB_ADDR_WIDTH),
    .APB_FIFO_APB2DMA_ADDR_WIDTH (APB_FIFO_APB2DMA_ADDR_WIDTH),
    .DATA_WIDTH                  (DATA_WIDTH),
    .APB_DATA_WIDTH              (APB_DATA_WIDTH)
    ) axil_dma (
      .aclk            (aclk),
      .pclk            (pclk),
      .anreset         (anreset),
      .pnreset         (pnreset),
      .aenable         (aenable),
      .penable         (penable),
      .i_abort         ({0,0}),
      .o_desc_rd       (axil_dma__desc_rd),
      .i_desc_endian   (dma_risc_bridge__desc_endian),
      .i_desc_write    (dma_risc_bridge__desc_write),
      .i_desc_ch_sel   (dma_risc_bridge__desc_ch_sel),
      .i_desc_len      (dma_risc_bridge__desc_len),
      .i_desc_size     (dma_risc_bridge__desc_size),
      .i_desc_burst    (dma_risc_bridge__desc_burst),
      .i_desc_sel      (dma_risc_bridge__desc_sel),
      .i_desc_id       (dma_risc_bridge__desc_id),
      .i_desc_dma_addr (dma_risc_bridge__desc_dma_addr),
      .i_desc_mem_addr (dma_risc_bridge__desc_mem_addr),
      .i_desc_rready   (dma_risc_bridge__desc_rready),
      .o_resp_wr       (axil_dma__resp_wr),
      .o_resp_desc_id  (axil_dma__resp_desc_id),
      .o_resp_ch_sel   (axil_dma__resp_ch_sel),
      .i_resp_wready   (dma_risc_bridge__resp_wready),
      .o_awaddr        (axil_dma__awaddr),
      .o_awprot        (axil_dma__awprot),
      .o_awvalid       (axil_dma__awvalid),
      .i_awready       (axil_interconnect__awready[0]),
      .o_wdata         (axil_dma__wdata),
      .o_wstrb         (axil_dma__wstrb),
      .o_wvalid        (axil_dma__wvalid),
      .i_wready        (axil_interconnect__wready[0]),
      .i_bresp         (axil_interconnect__bresp[1:0]),
      .i_bvalid        (axil_interconnect__bvalid[0]),
      .o_bready        (axil_dma__bready),
      .o_araddr        (axil_dma__araddr),
      .o_arprot        (axil_dma__arprot),
      .o_arvalid       (axil_dma__arvalid),
      .i_arready       (axil_interconnect__arready[0]),
      .i_rdata         (axil_interconnect__rdata[DATA_WIDTH - 1:0]),
      .i_rresp         (axil_interconnect__rresp[1:0]),
      .i_rvalid        (axil_interconnect__rvalid[0]),
      .o_rready        (axil_dma__rready),
      .i_pready_0      (apb_slave__pready_0),
      .i_pready_1      (apb_slave__pready_1),
      .i_prdata_0      (apb_slave__prdata_0),
      .i_prdata_1      (apb_slave__prdata_1),
      .o_penable       (axil_dma__penable),
      .o_psel_0        (axil_dma__psel_0),
      .o_psel_1        (axil_dma__psel_1),
      .o_pwrite        (axil_dma__pwrite),
      .o_pwdata_0      (axil_dma__pwdata_0),
      .o_pwdata_1      (axil_dma__pwdata_1),
      .o_paddr         (axil_dma__paddr)
    );
  
  axil_ram # (
    .DATA_WIDTH (DATA_WIDTH),
    .ADDR_WIDTH (ADDR_WIDTH)
    ) axil_ram (
      .clk             (aclk),
      .rst             (~anreset),
      .s_axil_awaddr   (axil_ram__awaddr),
      .s_axil_awprot   (axil_ram__awprot),
      .s_axil_awvalid  (axil_ram__awvalid),
      .s_axil_awready  (axil_ram__awready),
      .s_axil_wdata    (axil_ram__wdata),
      .s_axil_wstrb    (axil_ram__wstrb),
      .s_axil_wvalid   (axil_ram__wvalid),
      .s_axil_wready   (axil_ram__wready),
      .s_axil_bresp    (axil_ram__bresp),
      .s_axil_bvalid   (axil_ram__bvalid),
      .s_axil_bready   (axil_ram__bready),
      .s_axil_araddr   (axil_ram__araddr),
      .s_axil_arprot   (axil_ram__arprot),
      .s_axil_arvalid  (axil_ram__arvalid),
      .s_axil_arready  (axil_ram__arready),
      .s_axil_rdata    (axil_ram__rdata),
      .s_axil_rresp    (axil_ram__rresp),
      .s_axil_rvalid   (axil_ram__rvalid),
      .s_axil_rready   (axil_ram__rready)
    );
  
  axil_interconnect #(
    .S_COUNT    (S_COUNT),
    .M_COUNT    (M_COUNT),
    .DATA_WIDTH (DATA_WIDTH),
    .ADDR_WIDTH (ADDR_WIDTH)
    ) axil_interconnect (
      .clk             (aclk),
      .rst             (~anreset),
      // AXI lite slave interfaces
      .s_axil_awaddr   ({riscv_top__awaddr, axil_dma__awaddr}),
      .s_axil_awprot   ({riscv_top__awprot, axil_dma__awprot}),
      .s_axil_awvalid  ({riscv_top__awvalid, axil_dma__awvalid}),
      .s_axil_awready  ({axil_interconnect__awready}),
      .s_axil_wdata    ({riscv_top__wdata, axil_dma__wdata}),
      .s_axil_wstrb    ({riscv_top__wstrb, axil_dma__wstrb}),
      .s_axil_wvalid   ({riscv_top__wvalid, axil_dma__wvalid}),
      .s_axil_wready   ({axil_interconnect__wready}),
      .s_axil_bresp    ({axil_interconnect__bresp}),
      .s_axil_bvalid   ({axil_interconnect__bvalid}),
      .s_axil_bready   ({riscv_top__bready, axil_dma__bready}),
      .s_axil_araddr   ({riscv_top__araddr, axil_dma__araddr}),
      .s_axil_arprot   ({riscv_top__arprot, axil_dma__arprot}),
      .s_axil_arvalid  ({riscv_top__arvalid, axil_dma__arvalid}),
      .s_axil_arready  ({axil_interconnect__arready}),
      .s_axil_rdata    ({axil_interconnect__rdata}),
      .s_axil_rresp    ({axil_interconnect__rresp}),
      .s_axil_rvalid   ({axil_interconnect__rvalid}),
      .s_axil_rready   ({riscv_top__rready, axil_dma__rready}),
      // AXI lite master interfaces
      .m_axil_awaddr   ({axil_ram__awaddr}),
      .m_axil_awprot   ({axil_ram__awprot}),
      .m_axil_awvalid  ({axil_ram__awvalid}),
      .m_axil_awready  ({axil_ram__awready}),
      .m_axil_wdata    ({axil_ram__wdata}),
      .m_axil_wstrb    ({axil_ram__wstrb}),
      .m_axil_wvalid   ({axil_ram__wvalid}),
      .m_axil_wready   ({axil_ram__wready}),
      .m_axil_bresp    ({axil_ram__bresp}),
      .m_axil_bvalid   ({axil_ram__bvalid}),
      .m_axil_bready   ({axil_ram__bready}),
      .m_axil_araddr   ({axil_ram__araddr}),
      .m_axil_arprot   ({axil_ram__arprot}),
      .m_axil_arvalid  ({axil_ram__arvalid}),
      .m_axil_arready  ({axil_ram__arready}),
      .m_axil_rdata    ({axil_ram__rdata}),
      .m_axil_rresp    ({axil_ram__rresp}),
      .m_axil_rvalid   ({axil_ram__rvalid}),
      .m_axil_rready   ({axil_ram__rready})
    );
  
endmodule
