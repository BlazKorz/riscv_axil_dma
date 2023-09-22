import riscv_pkg::*;

module riscv_su_arbiter #(
  parameter ADDR_WIDTH = 64,
  parameter SU_FSM_WIDTH = 3
  )(
  input clk,
  input nreset,
  input enable,
  
  input i_abort,
  input i_start,
  input i_all_in_stacked,
  input i_interr_preemtion,
  input i_ret_interr,
  input i_all_unstacked,
  
  output [SU_FSM_WIDTH - 1:0] o_fsm_status
  );
  
  localparam FSM_SU_IDLE = 0;
  localparam FSM_SU_STACKING = 1;
  localparam FSM_SU_INTERRUPT_PENDING = 2;
  localparam FSM_SU_INTERRUPT_PREEMTION = 3;
  localparam FSM_SU_UNSTACKING = 4;
  localparam FSM_SU_ABORTING = 5;
  localparam FSM_SU_110 = 6;
  localparam FSM_SU_111 = 7;
  
  wire start_c;
  wire abord_comp_c;
  wire all_in_stacked_c;
  wire all_unstacked_c;
  wire ret_interr_c;
  wire interr_preemtion_c;
  wire abord_completed_c;
  
  reg [SU_FSM_WIDTH - 1:0] stu_fsm_nxt_c;
  
  reg [SU_FSM_WIDTH - 1:0] stu_fsm_r;
  
  assign abord_comp_c = !i_abort;
  
  always_comb begin
    case (stu_fsm_r)
      FSM_SU_IDLE :
        stu_fsm_nxt_c = (start_c) ?            FSM_SU_STACKING :
                                               FSM_SU_IDLE;
      FSM_SU_STACKING :
        stu_fsm_nxt_c = (i_abort) ?            FSM_SU_ABORTING :
                        (all_in_stacked_c) ?   FSM_SU_INTERRUPT_PENDING :
                                               FSM_SU_STACKING;
      FSM_SU_INTERRUPT_PENDING :
        stu_fsm_nxt_c = (i_abort) ?            FSM_SU_ABORTING :
                        (interr_preemtion_c) ? FSM_SU_INTERRUPT_PREEMTION :
                        (ret_interr_c) ?       FSM_SU_UNSTACKING :
                                               FSM_SU_INTERRUPT_PENDING;
      FSM_SU_INTERRUPT_PREEMTION :
        stu_fsm_nxt_c = (i_abort) ?            FSM_SU_ABORTING :
                        (ret_interr_c) ?       FSM_SU_INTERRUPT_PENDING :
                                               FSM_SU_STACKING;
      FSM_SU_UNSTACKING :
        stu_fsm_nxt_c = (i_abort) ?            FSM_SU_ABORTING :
                        (all_unstacked_c) ?    FSM_SU_IDLE :
                                               FSM_SU_UNSTACKING;
      FSM_SU_ABORTING,
      FSM_SU_110,
      FSM_SU_111 :
        stu_fsm_nxt_c = (abord_comp_c) ?       FSM_SU_IDLE :
                                               FSM_SU_ABORTING;
      default :
        stu_fsm_nxt_c = {SU_FSM_WIDTH{1'hx}};      
    endcase
  end
  always_ff @(posedge clk or negedge nreset) begin
    if (!nreset) begin
      stu_fsm_r <= {SU_FSM_WIDTH{1'h0}};
    end else begin
      stu_fsm_r <= stu_fsm_nxt_c;
    end
  end
  
  assign o_fsm_status = stu_fsm_r;
  
endmodule