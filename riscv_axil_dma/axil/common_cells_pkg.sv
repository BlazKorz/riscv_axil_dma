package common_cells_pkg;
  
  localparam APB_CNT_WIDTH = 12;
  localparam AXIL_CNT_WIDTH = 8;
  
  localparam DMA_ARB_WR_FSM_WIDTH = 2;
  localparam FSM_DMA_ARB_WR_IDLE = 0;
  localparam FSM_DMA_ARB_WR_CH0 = 1;
  localparam FSM_DMA_ARB_WR_CH1 = 2;
  localparam FSM_DMA_ARB_WR_ABORTING = 3;
  
  localparam DMA_ARB_RD_FSM_WIDTH = 2;
  localparam FSM_DMA_ARB_RD_IDLE = 0;
  localparam FSM_DMA_ARB_RD_CH0 = 1;
  localparam FSM_DMA_ARB_RD_CH1 = 2;
  localparam FSM_DMA_ARB_RD_ABORTING = 3;
  
  localparam DMA_ARB_RSP_FSM_WIDTH = 2;
  localparam FSM_DMA_ARB_RSP_IDLE = 0;
  localparam FSM_DMA_ARB_RSP_CH0 = 1;
  localparam FSM_DMA_ARB_RSP_CH1 = 2;
  localparam FSM_DMA_ARB_RSP_ABORTING = 3;
  
  localparam DMA_APB_FSM_WIDTH = 2;
  localparam FSM_DMA_APB_IDLE = 0;
  localparam FSM_DMA_APB_SETUP = 1;
  localparam FSM_DMA_APB_ACCESS = 2;
  localparam FSM_DMA_APB_ABORTING = 3;
  
  localparam DMA_CHANNEL_FSM_WIDTH = 3;
  localparam FSM_DMA_CHANNEL_IDLE = 0;
  localparam FSM_DMA_CHANNEL_SETUP = 1;
  localparam FSM_DMA_CHANNEL_ACCESS = 2;
  localparam FSM_DMA_CHANNEL_RESPONSE = 3;
  localparam FSM_DMA_CHANNEL_ABORTING = 4;
  localparam FSM_DMA_CHANNEL_101 = 5;
  localparam FSM_DMA_CHANNEL_110 = 6;
  localparam FSM_DMA_CHANNEL_111 = 7;
  
  localparam FIXED = 1'b0;
  localparam INCR = 1'b1;
  
  localparam SIZE_1B = 2'b00;
  localparam SIZE_2B = 2'b01;
  localparam SIZE_4B = 2'b10;
  localparam SIZE_8B = 2'b11;
  
  
 `define RTL_REG_ASYNC(_clk, _nreset, _enable, _idata, _odata, DATA_WIDTH) \
    always_ff @(posedge _clk or negedge _nreset) begin \
      if (~_nreset) begin \
        _odata <= {DATA_WIDTH{1'h0}}; \
      end else if (_enable) begin \
        _odata <= _idata; \
      end \
    end
  
 `define RTL_RAM(_clk, _write, _idata, _iwraddr, _irdaddr, _ordmem, DATA_WIDTH, ADDR_WIDTH, MEM_DEPTH) \
    reg [DATA_WIDTH - 1:0] _mem [0:MEM_DEPTH - 1] = '{default:0}; \
    always_ff @(posedge _clk) begin \
      if (_write) begin \
        _mem [_iwraddr[ADDR_WIDTH - 1:0]] <= i_wr_data; \
      end \
    end \
    assign _ordmem = _mem [_irdaddr[ADDR_WIDTH - 1:0]];
  
  function bit[1:0] clog2 (input [3:0] i_value);
    begin
      clog2 = 0;
      for (bit[3:0] i = 0; 2**i < i_value; i = i + 1) begin
        clog2 = i + 1;
      end
    end
  endfunction
  
endpackage
