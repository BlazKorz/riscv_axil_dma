import common_cells_pkg::*;

module apb_tim #(
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
  output [3:0] o_tim_trigger
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
  
  localparam TIM_CTRL_ADDR = 0;
  localparam bit [DMA_TIM_ADDR_WIDTH:0] TIM_VALUE_ADDR [$clog2(DMA_APB_DATA_WIDTH)] = {1, 3, 5, 7};
  
  localparam CTRL_ENABLE      = 0;
  localparam CTRL_MODE        = 1;
  localparam CTRL_INTERR      = 2;
  localparam CTRL_SIZE        = 4;
  localparam CTRL_PRESCAL     = 6;
  localparam CTRL_WRAPPING    = 7;
  
  localparam CTRL_SIZE_16BIT  = 0;
  localparam CTRL_SIZE_32BIT  = 1;
  localparam CTRL_SIZE_48BIT  = 2;
  localparam CTRL_SIZE_64BIT  = 3;
  
  localparam CTRL_PRESCAL_0   = 0;
  localparam CTRL_PRESCAL_16  = 1;
  localparam CTRL_PRESCAL_64  = 2;
  localparam CTRL_PRESCAL_256 = 3;
  
  genvar tim_data_id;
  
  wire oneshot_mode_c;
  
  wire tim_en_c;
  assign tim_en_c = i_penable && i_psel && i_pwrite && penable;
  
  wire       tim_ctrl_en_c;
  wire [7:0] tim_ctrl_c;
  reg  [7:0] tim_ctrl_r;
  assign tim_ctrl_en_c = ((i_paddr[DMA_TIM_ADDR_WIDTH - 1:0] == TIM_CTRL_ADDR) && tim_en_c) || oneshot_mode_c;
  assign tim_ctrl_c    = (oneshot_mode_c) ? {tim_ctrl_r[CTRL_WRAPPING:CTRL_MODE], 1'h0} : 
                                            {i_pwdata[CTRL_WRAPPING],
                                             i_pwdata[CTRL_PRESCAL:CTRL_PRESCAL - 1],
                                             i_pwdata[CTRL_SIZE:CTRL_SIZE - 1],
                                             i_pwdata[CTRL_INTERR],
                                             i_pwdata[CTRL_MODE],
                                             i_pwdata[CTRL_ENABLE]};
  always_ff @(posedge pclk or negedge pnreset) begin
    if (!pnreset) begin
      tim_ctrl_r <= 8'h0;
    end else if (tim_ctrl_en_c) begin
      tim_ctrl_r <= tim_ctrl_c;
    end
  end
  
  wire cnt_overflow_c;
  assign oneshot_mode_c = ~tim_ctrl_r[CTRL_WRAPPING] && cnt_overflow_c;
  
  wire                            tim_data_en_c [$clog2(DMA_APB_DATA_WIDTH)];
  reg  [DMA_APB_DATA_WIDTH - 1:0] tim_data_r    [$clog2(DMA_APB_DATA_WIDTH)];
  generate
    for (tim_data_id = 0; tim_data_id < $clog2(DMA_APB_DATA_WIDTH); tim_data_id++) begin
      assign tim_data_en_c[tim_data_id] = (i_paddr[DMA_TIM_ADDR_WIDTH:0] == TIM_VALUE_ADDR[tim_data_id]) && tim_en_c;
      always_ff @(posedge pclk or negedge pnreset) begin
        if (!pnreset) begin
          tim_data_r[tim_data_id] <= {DMA_APB_DATA_WIDTH{1'h0}};
        end else if (tim_data_en_c[tim_data_id]) begin
          tim_data_r[tim_data_id] <= i_pwdata;
        end
      end
    end
  endgenerate
  
  wire       prescal_en_c;
  wire       prescal_overflow_c;
  wire [9:0] prescal_c;
  wire [9:0] prescal_overflow_value_c;
  reg  [9:0] prescal_r;
  assign prescal_en_c = (tim_ctrl_r[CTRL_PRESCAL:CTRL_PRESCAL - 1] != CTRL_PRESCAL_0) && penable;
  assign prescal_overflow_value_c = (tim_ctrl_r[CTRL_PRESCAL:CTRL_PRESCAL - 1] == CTRL_PRESCAL_16) ? 16 :
                                    (tim_ctrl_r[CTRL_PRESCAL:CTRL_PRESCAL - 1] == CTRL_PRESCAL_64) ? 64 :
                                                                                                     256;
  assign prescal_overflow_c       = (prescal_r == prescal_overflow_value_c);
  assign prescal_c                = (prescal_overflow_c) ? {DMA_TIM_DATA_WIDTH{1'h0}} :
                                                            prescal_r + 'h1;
  always_ff @(posedge pclk or negedge pnreset) begin
    if (!pnreset) begin
      prescal_r <= {DMA_TIM_DATA_WIDTH{1'h0}};
    end else if (prescal_en_c) begin
      prescal_r <= prescal_c;
    end
  end
  
  wire prescal_trigger_c;
  assign prescal_trigger_c = (prescal_en_c) ? prescal_overflow_c :
                                              1'h1;
  
  wire                            cnt_en_c;
  wire [DMA_TIM_DATA_WIDTH - 1:0] cnt_c;
  wire [DMA_TIM_DATA_WIDTH - 1:0] cnt_overflow_value_c;
  reg  [DMA_TIM_DATA_WIDTH - 1:0] cnt_r;
  assign cnt_en_c             = tim_ctrl_r[CTRL_ENABLE] && prescal_trigger_c && penable;
  assign cnt_overflow_value_c = (tim_ctrl_r[CTRL_MODE]) ?
                                (tim_ctrl_r[CTRL_SIZE:CTRL_SIZE - 1] == CTRL_SIZE_16BIT) ? {{DMA_APB_DATA_WIDTH*3{1'h0}},                               tim_data_r[0]} :
                                (tim_ctrl_r[CTRL_SIZE:CTRL_SIZE - 1] == CTRL_SIZE_32BIT) ? {{DMA_APB_DATA_WIDTH*2{1'h0}},                tim_data_r[1], tim_data_r[0]} :
                                (tim_ctrl_r[CTRL_SIZE:CTRL_SIZE - 1] == CTRL_SIZE_48BIT) ? {{DMA_APB_DATA_WIDTH*1{1'h0}}, tim_data_r[2], tim_data_r[1], tim_data_r[0]} :
                                                                                           {tim_data_r[3],                tim_data_r[2], tim_data_r[1], tim_data_r[0]} :            
                                (tim_ctrl_r[CTRL_SIZE:CTRL_SIZE - 1] == CTRL_SIZE_16BIT) ? {{DMA_APB_DATA_WIDTH*3{1'h0}}, {DMA_APB_DATA_WIDTH*1{1'h1}}} :
                                (tim_ctrl_r[CTRL_SIZE:CTRL_SIZE - 1] == CTRL_SIZE_32BIT) ? {{DMA_APB_DATA_WIDTH*2{1'h0}}, {DMA_APB_DATA_WIDTH*2{1'h1}}} :
                                (tim_ctrl_r[CTRL_SIZE:CTRL_SIZE - 1] == CTRL_SIZE_48BIT) ? {{DMA_APB_DATA_WIDTH*1{1'h0}}, {DMA_APB_DATA_WIDTH*3{1'h1}}} :
                                                                                           {DMA_APB_DATA_WIDTH*4{1'h1}};
  assign cnt_overflow_c       = (cnt_r == cnt_overflow_value_c);
  assign cnt_c                = (cnt_overflow_c) ? {DMA_TIM_DATA_WIDTH{1'h0}} :
                                                   cnt_r + 'h1;
  always_ff @(posedge pclk or negedge pnreset) begin
    if (!pnreset) begin
      cnt_r <= {DMA_TIM_DATA_WIDTH{1'h0}};
    end else if (cnt_en_c) begin
      cnt_r <= cnt_c;
    end
  end
  
  wire pready_en_c;
  wire pready_c;
  reg  pready_r;
  assign pready_en_c = (pready_r || (i_penable && i_psel)) && penable;
  assign pready_c    = (~pready_r) ? 'h1 : 'h0;
  always_ff @(posedge pclk or negedge pnreset) begin
    if (!pnreset) begin
      pready_r <= 1'h0; 
    end else if (pready_en_c) begin
      pready_r <= pready_c;
    end
  end
  
  assign o_pready      = pready_r;
  assign o_tim_trigger = cnt_overflow_c;
  assign o_prdata      = {DMA_APB_DATA_WIDTH{1'h1}};
  
  wire unused_ok = &{i_paddr[DMA_APB_ADDR_WIDTH - 1:DMA_TIM_ADDR_WIDTH / 2]};
  
endmodule
