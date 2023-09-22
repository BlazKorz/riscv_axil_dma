import riscv_pkg::*;

module riscv_ras_arbiter #(
  parameter ADDR_WIDTH = 64,
  parameter RAS_DEPTH = 16,
  parameter RAS_FSM_WIDTH = 3
  )(
  input clk,
  input nreset,
  input enable,
  
  input i_abort,
  input i_push,
  input i_pop,
  input i_pop_then_push,
  
  output o_push,
  output o_pop,
  
  output [RAS_FSM_WIDTH - 1:0] o_fsm_status,
  
  output [ADDR_WIDTH - 1:0] o_push_addr,
  output [ADDR_WIDTH - 1:0] o_pop_addr
  );
  
  localparam FSM_RAS_IDLE          = 0;
  localparam FSM_RAS_POP           = 1;
  localparam FSM_RAS_POP_THEN_PUSH = 2;
  localparam FSM_RAS_PUSH          = 3;
  localparam FSM_RAS_ABORTING      = 4;
  localparam FSM_RAS_101           = 5;
  localparam FSM_RAS_110           = 6;
  localparam FSM_RAS_111           = 7;
  
  wire ras_cnt_en_c;
    
  wire abord_comp_c;
  wire push_c;
  wire pop_c;
  
  wire [RAS_DEPTH - 1:0] ras_nxt_c;
  wire [RAS_DEPTH - 1:0] pop_addr_c;
  
  reg [RAS_FSM_WIDTH - 1:0] ras_fsm_nxt_c;
    
  reg [RAS_DEPTH - 1:0] ras_cnt_r;
  reg [RAS_FSM_WIDTH - 1:0] ras_fsm_r;
  
  assign abord_comp_c = !i_abort;
  
  always_comb begin
    case (ras_fsm_r)
      FSM_RAS_IDLE :
        ras_fsm_nxt_c = (i_pop) ?           FSM_RAS_POP :
                        (i_pop_then_push) ? FSM_RAS_POP_THEN_PUSH :
                        (i_push) ?          FSM_RAS_PUSH :
                                            FSM_RAS_IDLE;
      FSM_RAS_POP :
        ras_fsm_nxt_c = (i_abort) ?         FSM_RAS_ABORTING :
                                            FSM_RAS_IDLE;
      FSM_RAS_POP_THEN_PUSH :
        ras_fsm_nxt_c = (i_abort) ?         FSM_RAS_ABORTING :
                                            FSM_RAS_IDLE;
      FSM_RAS_PUSH :
        ras_fsm_nxt_c = (i_abort) ?         FSM_RAS_ABORTING :
                                            FSM_RAS_IDLE;
      FSM_RAS_ABORTING,
      FSM_RAS_101,
      FSM_RAS_110,
      FSM_RAS_111 :
        ras_fsm_nxt_c = (abord_comp_c) ?    FSM_RAS_IDLE :
                                            FSM_RAS_ABORTING;
      default :
        ras_fsm_nxt_c = {RAS_FSM_WIDTH{1'hx}};
    endcase
  end
  always_ff @(posedge clk or negedge nreset) begin
    if (!nreset) begin
      ras_fsm_r <= {RAS_FSM_WIDTH{1'h0}};
    end else begin
      ras_fsm_r <= ras_fsm_nxt_c;
    end
  end
  
  assign push_c = (ras_fsm_r == FSM_RAS_PUSH) || (ras_fsm_r == FSM_RAS_POP_THEN_PUSH);
  assign pop_c = (ras_fsm_r == FSM_RAS_POP) || (ras_fsm_r == FSM_RAS_POP_THEN_PUSH);
  
  assign ras_cnt_en_c = (push_c || pop_c) && enable;
  assign ras_nxt_c = (push_c & ~pop_c) ? (ras_cnt_r + 1) :
                     (~push_c & pop_c) ? (ras_cnt_r - 1) :
                                         (ras_cnt_r);
  always_ff @(posedge clk or negedge nreset) begin
    if (!nreset) begin
      ras_cnt_r <= {$clog2(RAS_DEPTH){1'h0}};
    end else if (ras_cnt_en_c) begin
      ras_cnt_r <= ras_nxt_c;
    end
  end
  
  assign pop_addr_c = (ras_cnt_r < 2) ? 0 : ras_cnt_r - 2;
  
  assign o_push = push_c;
  assign o_pop = pop_c;
  assign o_fsm_status = ras_fsm_r;
  assign o_push_addr = {({(ADDR_WIDTH - $clog2(RAS_DEPTH)){1'h0}}), ras_cnt_r};
  assign o_pop_addr = {({(ADDR_WIDTH - $clog2(RAS_DEPTH)){1'h0}}), pop_addr_c};
  
endmodule
