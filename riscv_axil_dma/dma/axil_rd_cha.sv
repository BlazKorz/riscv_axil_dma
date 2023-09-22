module axil_rd_cha #(
  parameter ADDR_WIDTH = 16,
  parameter DATA_WIDTH = 64,
  parameter STRB_WIDTH = (DATA_WIDTH / 8)
  )(
  input aclk,
  input anreset,
  input aenable,
  
  input i_rd_ready,
  input [ADDR_WIDTH - 1:0] i_rd_addr,
  output o_rd_valid,
  output [DATA_WIDTH - 1:0] o_rd_data,
  
  output [ADDR_WIDTH - 1:0] o_araddr,
  output [2:0] o_arprot,
  output o_arvalid,
  input i_arready,
  input [DATA_WIDTH - 1:0] i_rdata,
  input [1:0] i_rresp,
  input i_rvalid,
  output o_rready
  );
  
  localparam OKAY = 2'h0;
  
  wire                    axil_rd_en_c;
  wire                    arvalid_c;
  reg                     arvalid_r;
  wire                    rready_c;
  reg                     rready_r;
  wire [2:0]              arprot_c;
  reg  [2:0]              arprot_r;
  wire [ADDR_WIDTH - 1:0] araddr_c;
  reg  [ADDR_WIDTH - 1:0] araddr_r;
  wire [DATA_WIDTH - 1:0] rd_data_c;
  
  assign axil_rd_en_c = aenable;
  
  assign rready_c = (rready_r) ?
                    (i_rvalid) ?   1'h0 :
                                   rready_r:
                    (i_rd_ready) ? 1'h1 :
                                   1'h0;
 `RTL_REG_ASYNC (aclk, anreset, axil_rd_en_c, rready_c, rready_r, 1);
  
  assign arvalid_c = (rready_r) ?
                     (i_arready) ?  1'h0 :
                                    arvalid_r:
                     (i_rd_ready) ? 1'h1 :
                                    1'h0;
 `RTL_REG_ASYNC (aclk, anreset, axil_rd_en_c, arvalid_c, arvalid_r, 1);
  
  assign arprot_c = 3'h0;
 `RTL_REG_ASYNC (aclk, anreset, axil_rd_en_c, arprot_c, arprot_r, 3);
  
  assign araddr_c = i_rd_addr;
 `RTL_REG_ASYNC (aclk, anreset, axil_rd_en_c, araddr_c, araddr_r, ADDR_WIDTH);
  
  assign rd_data_c = (i_rvalid && i_rresp == OKAY) ? i_rdata :
                                                     {DATA_WIDTH{1'h1}};
  
  assign o_rready = rready_r;
  assign o_arvalid = arvalid_r;
  assign o_arprot = arprot_r;
  assign o_araddr = araddr_r;
  assign o_rd_valid = i_rvalid;
  assign o_rd_data = rd_data_c;
  
endmodule
