import riscv_pkg::*;

module riscv_top #(
  parameter ADDR_WIDTH = 64,
  parameter DATA_WIDTH = 64,
  parameter RAS_DEPTH = 16,
  parameter INSTR_WIDTH = 32,
  parameter STRB_WIDTH = DATA_WIDTH / 8
  )(
  input clk,
  input nreset,
  input enable,
  
  input i_instr_valid,
  
  input [INSTR_WIDTH - 1:0] i_instr,
  
  output o_read_instr,
  output o_busy,
  
  output [ADDR_WIDTH - 1:0] o_pc,
  
  output o_desc_wr,
  output o_desc_endian,
  output o_desc_write,
  output [1:0] o_desc_ch_sel,
  output [7:0] o_desc_len,
  output [2:0] o_desc_size,
  output [1:0] o_desc_burst,
  output [3:0] o_desc_sel,
  output [7:0] o_desc_id,
  output [ADDR_WIDTH - 1:0] o_desc_dma_addr,
  output [ADDR_WIDTH - 1:0] o_desc_mem_addr,
  input i_desc_wready,
  
  output o_resp_rd,
  input [7:0] i_resp_desc_id,
  input [1:0] i_resp_ch_sel,
  input i_resp_rready,
  
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
  output o_bready,
  
  output [ADDR_WIDTH - 1:0] o_araddr,
  output [2:0] o_arprot,
  output o_arvalid,
  input i_arready,
  input [DATA_WIDTH - 1:0] i_rdata,
  input [1:0] i_rresp,
  input i_rvalid,
  output o_rready
  );
  
  wire                    axil_if__wr_ready;
  wire [DATA_WIDTH - 1:0] axil_if__rd_data;
  wire                    axil_if__rd_valid;
  
  wire [DATA_WIDTH - 1:0] riscv_cache_data;
  
  wire                    riscv_main_unit__cache_read;
  wire                    riscv_main_unit__cache_write;
  wire [DATA_WIDTH - 1:0] riscv_main_unit__cache_wr_data;
  wire [ADDR_WIDTH - 1:0] riscv_main_unit__cache_rd_addr;
  wire [ADDR_WIDTH - 1:0] riscv_main_unit__cache_wr_addr;
  wire                    riscv_main_unit__wr_valid;
  wire [STRB_WIDTH - 1:0] riscv_main_unit__wr_strb;
  wire [DATA_WIDTH - 1:0] riscv_main_unit__wr_data;
  wire                    riscv_main_unit__rd_ready;
  wire [ADDR_WIDTH - 1:0] riscv_main_unit__addr;
  
  axil_if # (
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH)
    ) axil_riscv_if (
      .aclk            (clk),
      .anreset         (nreset),
      .aenable         (enable),
      .i_wr_valid      (riscv_main_unit__wr_valid),
      .i_wr_strb       (riscv_main_unit__wr_strb),
      .i_wr_data       (riscv_main_unit__wr_data),
      .i_wr_addr       (riscv_main_unit__addr),
      .o_wr_ready      (axil_if__wr_ready),
      .i_rd_ready      (riscv_main_unit__rd_ready),
      .i_rd_addr       (riscv_main_unit__addr),
      .o_rd_valid      (axil_if__rd_valid),
      .o_rd_data       (axil_if__rd_data),
      .o_awaddr        (o_awaddr),
      .o_awprot        (o_awprot),
      .o_awvalid       (o_awvalid),
      .i_awready       (i_awready),
      .o_wdata         (o_wdata),
      .o_wstrb         (o_wstrb),
      .o_wvalid        (o_wvalid),
      .i_wready        (i_wready),
      .i_bresp         (i_bresp),
      .i_bvalid        (i_bvalid),
      .o_bready        (o_bready),
      .o_araddr        (o_araddr),
      .o_arprot        (o_arprot),
      .o_arvalid       (o_arvalid),
      .i_arready       (i_arready),
      .i_rdata         (i_rdata),
      .i_rresp         (i_rresp),
      .i_rvalid        (i_rvalid),
      .o_rready        (o_rready)
    );
    
  riscv_cache #(
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH)
    ) riscv_cache (
      .clk             (clk),
      .nreset          (nreset),
      .enable          (enable),
      .i_read          (riscv_main_unit__cache_read),
      .i_write         (riscv_main_unit__cache_write),
      .i_data          (riscv_main_unit__cache_wr_data),
      .i_rd_addr       (riscv_main_unit__cache_rd_addr),
      .i_wr_addr       (riscv_main_unit__cache_wr_addr),
      .o_data          (riscv_cache_data)
    );
    
  riscv_main_unit #(
    .ADDR_WIDTH  (ADDR_WIDTH),
    .DATA_WIDTH  (DATA_WIDTH),
    .RAS_DEPTH   (RAS_DEPTH),
    .INSTR_WIDTH (INSTR_WIDTH)
    ) riscv_main_unit (
      .clk             (clk),
      .nreset          (nreset),
      .enable          (enable),
      .i_instr_valid   (i_instr_valid),
      .i_instr         (i_instr),
      .o_pc            (o_pc),
      .o_read_instr    (o_read_instr),
      .i_desc_wready   (i_desc_wready),
      .o_desc_data     ({o_desc_endian,
                         o_desc_write,
                         o_desc_ch_sel,
                         o_desc_len,
                         o_desc_size,
                         o_desc_burst,
                         o_desc_sel,
                         o_desc_id,
                         o_desc_dma_addr,
                         o_desc_mem_addr}),
      .o_desc_wr       (o_desc_wr),
      .i_resp_data     ({i_resp_ch_sel,
                         i_resp_desc_id}),
      .i_resp_rready   (i_resp_rready),
      .o_resp_rd       (o_resp_rd),
      .o_mem_wr_valid  (riscv_main_unit__wr_valid),
      .o_mem_wr_strb   (riscv_main_unit__wr_strb),
      .o_mem_wr_data   (riscv_main_unit__wr_data),
      .i_mem_wr_ready  (axil_if__wr_ready),
      .o_mem_rd_ready  (riscv_main_unit__rd_ready),
      .i_mem_rd_data   (axil_if__rd_data),
      .i_mem_rd_valid  (axil_if__rd_valid),
      .o_mem_addr      (riscv_main_unit__addr),
      .o_busy          (o_busy),
      .i_cache_data    (riscv_cache_data),
      .o_cache_read    (riscv_main_unit__cache_read),
      .o_cache_write   (riscv_main_unit__cache_write),
      .o_cache_wr_data (riscv_main_unit__cache_wr_data),
      .o_cache_rd_addr (riscv_main_unit__cache_rd_addr),
      .o_cache_wr_addr (riscv_main_unit__cache_wr_addr)
    );
    
endmodule
