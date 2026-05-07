
module start_text_graphic
  import graphics_engine_pkg::*;
  import graphics_rom_pkg::*;
(
  input logic clk_i,
  input logic rst_ni,

  input sprite_input_t sprite_input,
  output sprite_output_t sprite_output
);

  pix_coord_t cx, cy, vx, vy;
  assign cx = sprite_input.center_pix.x;
  assign cy = sprite_input.center_pix.y;
  assign vx = sprite_input.vga_pos.x;
  assign vy = sprite_input.vga_pos.y;

  // Create the outer box
  localparam pix_coord_t OUTERBOX_WIDTH = 20;
  logic outerbox_active;
  assign outerbox_active = (
    vx-OUTERBOX_WIDTH < cx && cx < vx+OUTERBOX_WIDTH &&
    vy-OUTERBOX_WIDTH < cy && cy < vy+OUTERBOX_WIDTH
  );

  logic white;
  assign white = outerbox_active;

  assign sprite_output.color = {white, 1'b0, white, 1'b0};

endmodule