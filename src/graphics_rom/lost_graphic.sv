
module lost_graphic
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

  localparam pix_coord_t BOX_WIDTH = 30;
  logic box_active;
  assign box_active = (
    vx - BOX_WIDTH < cx && cx < vx + BOX_WIDTH &&
    vy - BOX_WIDTH < cy && cy < vy + BOX_WIDTH
  );

  // Red: R=1, G=0, B=0 → argb = {alpha, 1, 0, 0}
  assign sprite_output.color = {box_active, box_active, 1'b0, 1'b0};

endmodule
