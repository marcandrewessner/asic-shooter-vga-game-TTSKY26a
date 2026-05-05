
`include "ff_macros.svh"

module crosshair_control
  import game_logic_pkg::*;
#(
  parameter game_coord_t MOVEMENT_SPEED = 8,
  parameter game_pos_t RESET_POSITION = game_pos_t'{x: 100, y:200}
)
(
  input logic clk_i,
  input logic rst_ni,
  input logic clk_virt_i,

  input logic btn_up_i,
  input logic btn_down_i,
  input logic btn_right_i,
  input logic btn_left_i,

  // Control inputs
  input logic pos_reset,
  input logic pos_lock,

  // Push the output position
  output game_pos_t pos_o
);

  game_pos_t pos_d, pos_q;

  always_comb begin
    pos_d = pos_q;
    // advance according to input
    if(!pos_lock) begin
      pos_d.x = pos_d.x + (btn_right_i ? MOVEMENT_SPEED : 0) - (btn_left_i ? MOVEMENT_SPEED : 0);
      pos_d.y = pos_d.y + (btn_down_i ? MOVEMENT_SPEED : 0) - (btn_up_i ? MOVEMENT_SPEED : 0);
    end
    // reset if requested
    if(pos_reset)
      pos_d = RESET_POSITION;
  end

  `FFAR_EN(clk_i, rst_ni, RESET_POSITION, pos_q, pos_d, clk_virt_i)

  assign pos_o = pos_q;

endmodule