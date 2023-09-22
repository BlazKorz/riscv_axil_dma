import riscv_pkg::*;

module riscv_mu_status_manager #(

  )(
  input clk,
  input nreset,
  input enable,
  
  input i_flush_if,
  
  output o_busy
  );
  
  wire risc_status_manager_en_c;
  
  wire busy_c;
  
  reg busy_r;
  
  assign risc_status_manager_en_c = enable;
  assign busy_c = i_flush_if;
  always_ff @(posedge clk or negedge nreset) begin
    if (!nreset) begin
      busy_r <= 1'b0;
    end else if (risc_status_manager_en_c) begin
      busy_r <= busy_c;
    end
  end
  
  assign o_busy = i_flush_if;
  
endmodule
