
/*

This is the render engine, that gets connected
to the screen via VGA

*/


`default_nettype none

module render_engine
  import graphics_engine_pkg::*;
  import graphics_rom_pkg::*;
  import game_logic_pkg::*;
#(
  parameter int N_SHOTS = 10
) (
  input logic clk_i,
  input logic rst_ni,

  output logic end_of_frame_o,
  output logic hsync_o,
  output logic vsync_o,
  output rgb_t rgb_o,

  input logic draw_start_text_i,
  input logic draw_hit_i,
  input logic draw_won_i,
  input logic draw_lost_i,

  input logic draw_miss_i,
  input pix_pos_t miss_pos_i,

  input logic draw_crosshair_i,
  input pix_pos_t cross_pos_i,

  input logic draw_ghost_i,
  input pix_pos_t ghost_pos_i,

  input logic [N_SHOTS-1:0] shots_used_i,
  input logic [N_SHOTS-1:0] shots_hit_i,

  input logic game_tick_i
);

  //////////////////////////////////////////////
  // VGA //
  //////////////////////////////////////////////
  pix_pos_t vga_pos;
  vgatiming i_vgat (
      .clk_i            (clk_i),
      .rst_ni           (rst_ni),
      .in_active_frame_o(),
      .end_of_frame_o   (end_of_frame_o),
      .pixel_x_o        (vga_pos.x),
      .pixel_y_o        (vga_pos.y),
      .hsync_o          (hsync_o),
      .vsync_o          (vsync_o)
  );

  //////////////////////////////////////////////
  // crosshair sprite //
  //////////////////////////////////////////////
  argb_t         cross_color;

  sprite_input_t cross_input;
  assign cross_input.center_pix = cross_pos_i;
  assign cross_input.vga_pos    = vga_pos;

  sprite_output_t cross_output;
  assign cross_color = cross_output.color;

  crosshair_sprite i_crosshair_sprite (
      .clk_i        (clk_i),
      .rst_ni       (rst_ni),
      .sprite_input (cross_input),
      .sprite_output(cross_output)
  );

  //////////////////////////////////////////////
  // ghost sprite //
  //////////////////////////////////////////////
  argb_t         ghost_color;
  sprite_input_t ghost_input;
  assign ghost_input.center_pix = ghost_pos_i;
  assign ghost_input.vga_pos    = vga_pos;

  sprite_output_t ghost_output;
  assign ghost_color = ghost_output.color;

  bird_animated #(
    .FRAMES_P_STATE (5)
  ) i_bird_animated (
      .clk_i        (clk_i),
      .rst_ni       (rst_ni),
      .end_of_frame (game_tick_i),
      .sprite_input (ghost_input),
      .sprite_output(ghost_output)
  );

  //////////////////////////////////////////////
  // start text sprite //
  //////////////////////////////////////////////
  argb_t         start_txt_color;
  sprite_input_t start_txt_input;
  assign start_txt_input.center_pix = '{
    x: 10'(SCREEN_WIDTH/2),
    y: 10'(SCREEN_HEIGHT/2)
  };
  assign start_txt_input.vga_pos    = vga_pos;

  sprite_output_t start_txt_output;
  assign start_txt_color = start_txt_output.color;

  press_to_start_graphic i_press_to_start_graphic (
    .clk_i        (clk_i),
    .rst_ni       (rst_ni),
    .sprite_input (start_txt_input),
    .sprite_output(start_txt_output)
  );

  //////////////////////////////////////////////
  // miss graphic //
  //////////////////////////////////////////////
  argb_t miss_color;
  sprite_input_t miss_input;
  assign miss_input.center_pix = miss_pos_i;
  assign miss_input.vga_pos = vga_pos;

  sprite_output_t miss_output;
  assign miss_color = miss_output.color;

  miss_x i_miss_graphic (
    .clk_i, .rst_ni,
    .sprite_input (miss_input),
    .sprite_output(miss_output)
  );

  //////////////////////////////////////////////
  // won graphic //
  //////////////////////////////////////////////
  argb_t won_color;
  sprite_input_t won_input;
  assign won_input.center_pix = '{
    x: 10'(SCREEN_WIDTH/2),
    y: 10'(SCREEN_HEIGHT/2)
  };
  assign won_input.vga_pos = vga_pos;

  sprite_output_t won_output;
  assign won_color = won_output.color;

  won_graphic i_won_graphic (
    .clk_i, .rst_ni,
    .sprite_input (won_input),
    .sprite_output(won_output)
  );

  //////////////////////////////////////////////
  // lost graphic //
  //////////////////////////////////////////////
  argb_t lost_color;
  sprite_input_t lost_input;
  assign lost_input.center_pix = '{
    x: 10'(SCREEN_WIDTH/2),
    y: 10'(SCREEN_HEIGHT/2)
  };
  assign lost_input.vga_pos = vga_pos;

  sprite_output_t lost_output;
  assign lost_color = lost_output.color;

  lost_graphic i_lost_graphic (
    .clk_i, .rst_ni,
    .sprite_input (lost_input),
    .sprite_output(lost_output)
  );

  //////////////////////////////////////////////
  // reloading graphic //
  //////////////////////////////////////////////
  argb_t reloading_color;
  sprite_input_t reloading_input;
  assign reloading_input.center_pix = '{
    x: 10'(SCREEN_WIDTH/2),
    y: 10'(SCREEN_HEIGHT/4*3)
  };
  assign reloading_input.vga_pos = vga_pos;

  sprite_output_t reloading_output;
  assign reloading_color = reloading_output.color;

  reloading_graphic i_relaoding_graphic (
    .clk_i, .rst_ni,
    .sprite_input (reloading_input),
    .sprite_output(reloading_output)
  );

  //////////////////////////////////////////////
  // ui shots display //
  //////////////////////////////////////////////
  argb_t shots_ui_display_color;
  localparam pix_pos_t left_center_pos = '{
    x: 'd350,
    y: 'd450
  };

  shot_ui_display #(
    .N_SHOTS(N_SHOTS)
  ) i_shot_ui_display (
    .clk_i, .rst_ni,
    .left_center_pos ( left_center_pos),
    .vga_pos         ( vga_pos ),
    .shots_used_i    ( shots_used_i ),
    .shots_hit_i     ( shots_hit_i ),
    .color_o         ( shots_ui_display_color )
  );

  //////////////////////////////////////////////
  // draw the sprites layered //
  //////////////////////////////////////////////
  logic shots_ui_active;
  logic ghost_active;
  logic cross_active;
  logic start_txt_active;
  logic hit_active;
  logic miss_active;
  logic won_active;
  logic lost_active;
  logic reload_active;

  assign shots_ui_active  = shots_ui_display_color[3];
  assign start_txt_active = start_txt_color[3] & draw_start_text_i;
  assign ghost_active     = ghost_color[3]     & draw_ghost_i;
  assign cross_active     = cross_color[3]     & draw_crosshair_i;
  assign miss_active      = miss_color[3]      & draw_miss_i;
  assign won_active       = won_color[3]       & draw_won_i;
  assign lost_active      = lost_color[3]      & draw_lost_i;
  assign reload_active    = reloading_color[3] & (draw_hit_i || draw_miss_i);

  argb_t bird_color_filtered;
  always_comb begin
    bird_color_filtered = ghost_color;
    // turn blue to red if hit
    if(draw_hit_i && bird_color_filtered==4'b1001)
      bird_color_filtered = 4'b1100;
  end

  always_comb begin
    rgb_o = 3'b000;
    // Layers are built from top to bottom (first is top)!
    if      (shots_ui_active)  rgb_o = shots_ui_display_color[2:0];
    else if (won_active)       rgb_o = won_color[2:0];
    else if (lost_active)      rgb_o = lost_color[2:0];
    else if (start_txt_active) rgb_o = start_txt_color[2:0];
    else if (cross_active)     rgb_o = cross_color[2:0];
    else if (miss_active)      rgb_o = miss_color[2:0];
    else if (reload_active)    rgb_o = reloading_color[2:0];
    else if (ghost_active)     rgb_o = bird_color_filtered[2:0];
  end

endmodule
