module dma_apb_ctrl_logic #(
  parameter APB_SVL = 4,
  parameter APB_ADDR_WIDTH = 16,
  parameter APB_DATA_WIDTH = 16
  )(
  input i_pready [APB_SVL],
  input [$clog2(APB_SVL) - 1:0] i_psel,
  
  input [APB_DATA_WIDTH - 1:0] i_prdata [APB_SVL],
  
  output o_pready,
  output o_psel [APB_SVL],
  
  output [APB_DATA_WIDTH - 1:0] o_prdata 
  );
  
  wire psel_c [APB_SVL];
  wire [APB_SVL - 1:0] pready_c;
  reg [$clog2(APB_SVL) - 1:0] sel_c;
  
  generate
    for (genvar slv_id = 0; slv_id < APB_SVL; slv_id++) begin
      assign psel_c[slv_id] = (i_psel == slv_id) ? 1 : 0;
      assign pready_c[slv_id] = i_pready[slv_id];
    end
  endgenerate
  
  always_comb begin
    sel_c = 0;
    for (integer sel_id = 0; sel_id < APB_SVL; sel_id++) begin
      if (pready_c[sel_id]) begin
        sel_c = sel_id;
      end
    end
  end
  
  assign o_pready = |pready_c;
  assign o_psel = psel_c;
  assign o_prdata = i_prdata[sel_c];
  
endmodule
