
// This module is used to get the button inputs
// to be synchronized with the current system

module btn_cdc (
  input logic clk_i,
  input logic rst_ni,

  input logic btn_i,
  output logic btn_o
);

  // Just have the button buffered
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni)
      btn_o <= '0;
    else
      btn_o <= btn_i;
  end

endmodule