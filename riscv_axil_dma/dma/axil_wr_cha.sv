module axil_wr_cha #(
  parameter ADDR_WIDTH = 16,
  parameter DATA_WIDTH = 64,
  parameter STRB_WIDTH = (DATA_WIDTH / 8)
  )(
  input aclk,
  input anreset,
  input aenable,
  
  input i_wr_valid,
  input [STRB_WIDTH - 1:0] i_wr_strb,
  input [DATA_WIDTH - 1:0] i_wr_data,
  input [ADDR_WIDTH - 1:0] i_wr_addr,
  output o_wr_ready,
  
  output [ADDR_WIDTH - 1:0] o_awaddr,
  output [2:0] o_awprot,
  output o_awvalid,
  input i_awready,
  output [DATA_WIDTH - 1:0] o_wdata,
  output [STRB_WIDTH - 1:0] o_wstrb,
  output o_wvalid,
  input i_wready,
  input [1:0] i_bresp,
  input i_bvalid,
  output o_bready
  );
  
  wire                    axil_wr_en_c;
  wire                    awvalid_c;
  reg                     awvalid_r;
  wire                    wvalid_c;
  reg                     wvalid_r;
  wire                    bready_c;
  reg                     bready_r;
  reg  [2:0]              awprot_c;
  reg  [2:0]              awprot_r;
  wire [STRB_WIDTH - 1:0] wstrb_c;
  reg  [STRB_WIDTH - 1:0] wstrb_r;
  wire [DATA_WIDTH - 1:0] wdata_c;
  reg  [DATA_WIDTH - 1:0] wdata_r;
  reg  [ADDR_WIDTH - 1:0] waddr_c;
  reg  [ADDR_WIDTH - 1:0] waddr_r;
  
  assign axil_wr_en_c = aenable;
   
  assign awvalid_c = (bready_r) ?
                     (i_awready) ?  1'h0 :
                                    awvalid_r:
                     (i_wr_valid) ? 1'h1 :
                                    1'h0;
 `RTL_REG_ASYNC (aclk, anreset, axil_wr_en_c, awvalid_c, awvalid_r, 1);
  
  assign wvalid_c = (bready_r) ?
                    (i_wready) ?   1'h0 :
                                   wvalid_r:
                    (i_wr_valid) ? 1'h1 :
                                   1'h0;
 `RTL_REG_ASYNC (aclk, anreset, axil_wr_en_c, wvalid_c, wvalid_r, 1);
  
  assign bready_c = (bready_r) ?
                    (i_bvalid) ?   1'h0 :
                                   bready_r:
                    (i_wr_valid) ? 1'h1 :
                                   1'h0;
 `RTL_REG_ASYNC (aclk, anreset, axil_wr_en_c, bready_c, bready_r, 1);
  
  assign awprot_c = 3'h0;
 `RTL_REG_ASYNC (aclk, anreset, axil_wr_en_c, awprot_c, awprot_r, 3);
  
  assign wstrb_c = i_wr_strb;
 `RTL_REG_ASYNC (aclk, anreset, axil_wr_en_c, wstrb_c, wstrb_r, DATA_WIDTH);
  
  assign wdata_c = i_wr_data;
 `RTL_REG_ASYNC (aclk, anreset, axil_wr_en_c, wdata_c, wdata_r, STRB_WIDTH);
  
  assign waddr_c = i_wr_addr;
 `RTL_REG_ASYNC (aclk, anreset, axil_wr_en_c, waddr_c, waddr_r, ADDR_WIDTH);
  
  assign o_awvalid = awvalid_r;
  assign o_wvalid = wvalid_r;
  assign o_bready = bready_r;
  assign o_awprot = awprot_r;
  assign o_wstrb = wstrb_r;
  assign o_wdata = wdata_r;
  assign o_awaddr = waddr_r;
  assign o_wr_ready = i_bvalid;
  
  wire unused = &{i_bresp};
  
endmodule
