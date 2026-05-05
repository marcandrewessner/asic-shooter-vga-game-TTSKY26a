// These modules allow for edge detection
// either rising or falling of the button input

module btn_edge_detector #(
  // check what type of edge
  parameter string EDGE = "RISING" // only rising and falling allowed
) (
  input logic clk_i,
  input logic rst_ni,
  input logic clk_virt_i,

  input  logic signal_i,
  output logic edge_o
);

  // Assert at elaboration time that the input is wrong
  initial begin : p_assert
    assert (EDGE == "RISING" || EDGE == "FALLING")
      else $fatal(1, "Invalid EDGE parameter: %s", EDGE);
  end

  //////////////////////////////////////////
  // buffer the input and hold till clk_virt
  //////////////////////////////////////////
  logic buff_q;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni)
      buff_q <= '0;
    else
      buff_q <= signal_i;
  end
  
  //////////////////////////////////////////
  // edge detection and selection
  //////////////////////////////////////////
  logic sig_edge;
  logic rising_edge;
  logic falling_edge;

  assign rising_edge  = signal_i & ~buff_q;
  assign falling_edge = ~signal_i & buff_q;

  // on the edge do different operations (elaboration-time selection)
  generate
    if (EDGE == "RISING") begin
      assign sig_edge = rising_edge;
    end else begin
      assign sig_edge = falling_edge;
    end
  endgenerate

  //////////////////////////////////////////
  // hold the edge till clk_virt
  //////////////////////////////////////////
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni)
      edge_o <= '0;
    else
      edge_o <= sig_edge | (clk_virt_i ? 0 : edge_o);
  end

endmodule