
module maw_main
  import graphics_engine_pkg::*;
  import game_logic_pkg::*;
(
  input  logic       clk_i,
  input  logic       rst_ni,

  input logic  btn_up_i,
  input logic btn_down_i,
  input logic btn_left_i,
  input logic btn_right_i,
  input logic btn_action_i,

  output logic       hsync_o,
  output logic       vsync_o,
  output logic [2:0] rgb_o
);

  //////////////////////////////////////////////
  // prepare the btn signals (assigned below) //
  //////////////////////////////////////////////
  logic btn_up_sync, btn_up_held_edge_rising, btn_up_held_edge_falling;
  logic btn_down_sync, btn_down_held_edge_rising, btn_down_held_edge_falling;
  logic btn_left_sync, btn_left_held_edge_rising, btn_left_held_edge_falling;
  logic btn_right_sync, btn_right_held_edge_rising, btn_right_held_edge_falling;
  logic btn_action_sync, btn_action_held_edge_rising, btn_action_held_edge_falling;

  //////////////////////////////////////////////
  // prepare the logic and renderer signals //
  //////////////////////////////////////////////
  // Renderer //
  logic end_of_frame;
  pix_pos_t crosshair_pos_pix;
  pix_pos_t enemy_pos_pix;
  logic draw_ghost;
  logic draw_crosshair;
  logic draw_start_text;
  // Logic //
  localparam int N_SHOTS = 10;
  game_state_e game_state;
  logic [N_SHOTS-1:0] shots_used_history;
  logic [N_SHOTS-1:0] shots_hit_history;

  localparam game_pos_t CROSSHAIR_RESET_POS = '{x:150, y:100};
  logic crosshair_controller_reset, crosshair_controller_lock;
  game_pos_t crosshair_pos;
  
  game_pos_t enemy_pos;
  logic crosshair_on_enemy;
  
  logic shot_hit;
  logic shot_miss;

  logic [15:0] random_halfword;
 
  //////////////////////////////////////////////
  // instantiate game logic & rendering //
  //////////////////////////////////////////////

  game_state_fsm #(
    .N_SHOTS(N_SHOTS)
  ) i_game_state_fsm (
    .clk_i, .rst_ni,
    .end_of_frame_i         ( end_of_frame ),
    .btn_action_edge_held_i ( btn_action_held_edge_falling ),
    .missed_i               ( shot_miss ),
    .hit_i                  ( shot_hit ),
    .game_state_o           ( game_state ),
    .used_shots_o           ( shots_used_history ),
    .score_shots_o          ( shots_hit_history )
  );

  crosshair_control #(
    .RESET_POSITION(CROSSHAIR_RESET_POS)
  ) i_crosshair_control (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .clk_virt_i(end_of_frame),
    // Button inputs
    .btn_up_i(btn_up_sync),
    .btn_down_i(btn_down_sync),
    .btn_right_i(btn_right_sync),
    .btn_left_i(btn_left_sync),
    // Control inputs
    .pos_reset(crosshair_controller_reset),
    .pos_lock(crosshair_controller_lock),
    .pos_o(crosshair_pos)
  );

  localparam game_pos_t ENEMY_RST_POS = game_pos_t'{x:200, y:300};
  enemy_movement i_enemy_movement (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .clk_virt_i(end_of_frame),
    .rst_position_i(ENEMY_RST_POS),
    .rtl_i(1),
    .enemy_position_o(enemy_pos)
  );

  render_engine #(
    .N_SHOTS(N_SHOTS)
  ) i_render_engine (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .end_of_frame_o(end_of_frame),
    .hsync_o(hsync_o),
    .vsync_o(vsync_o),
    .rgb_o(rgb_o),
    // let the renderer know what to render
    .draw_ghost_i(draw_ghost),
    .draw_crosshair_i(draw_crosshair),
    .draw_start_text_i(draw_start_text),
    // let the renderer know where to render
    .cross_pos_i(crosshair_pos_pix),
    .ghost_pos_i(enemy_pos_pix),
    // pass in the history for ui
    .shots_used_i(shots_used_history),
    .shots_hit_i (shots_hit_history)
  );

  prng_lfsr16 #(
    .clk_i, .rst_ni,
    rnd_o ( random_halfword )
  );

  //////////////////////////////////////////////
  // populate game logic //
  //////////////////////////////////////////////
  always_comb begin : main_game_logic 
    // Set the crosshair control state
    crosshair_controller_lock = ~(
      game_state == GAME_STATE_SHOOTING  ||
      game_state == GAME_STATE_HIT       ||
      game_state == GAME_STATE_MISS
    );
    crosshair_controller_reset = (
      game_state == GAME_STATE_RESET         ||
      game_state == GAME_STATE_START_SCREEN
    );

    // Check if we point in the box
    crosshair_on_enemy = point_in_box(
      enemy_pos,
      crosshair_pos,
      '{x:100, y:100}
    );

    // Calculate hit or miss
    shot_hit  = btn_action_held_edge_rising & crosshair_on_enemy;
    shot_miss = btn_action_held_edge_rising & ~crosshair_on_enemy;

    // Decide what to draw on screen
    draw_ghost      = 1'b1;
    draw_crosshair  = 1'b1;
    draw_start_text = (game_state == GAME_STATE_START_SCREEN);

    // Game pos to screen pos
    crosshair_pos_pix = game2pix_pos_transformation(crosshair_pos);
    enemy_pos_pix     = game2pix_pos_transformation(enemy_pos);
  end






  //////////////////////////////////////////////
  // process and assign the btn signals //
  //////////////////////////////////////////////
  // button up
  btn_cdc i_btn_cdc_b_up (
    .clk_i, .rst_ni,
    .btn_i(btn_up_i), .btn_o(btn_up_sync)
  );
  btn_edge_detector #(
    .EDGE("RISING")
  ) i_btn_edge_b_up_rising (
    .clk_i, .rst_ni, .clk_virt_i(end_of_frame),
    .signal_i(btn_up_sync), .edge_o(btn_up_held_edge_rising)
  );
  btn_edge_detector #(
    .EDGE("FALLING")
  ) i_btn_edge_b_up_falling (
    .clk_i, .rst_ni, .clk_virt_i(end_of_frame),
    .signal_i(btn_up_sync), .edge_o(btn_up_held_edge_falling)
  );
  // button down
  btn_cdc i_btn_cdc_b_down (
    .clk_i, .rst_ni,
    .btn_i(btn_down_i), .btn_o(btn_down_sync)
  );
  btn_edge_detector #(
    .EDGE("RISING")
  ) i_btn_edge_b_down_rising (
    .clk_i, .rst_ni, .clk_virt_i(end_of_frame),
    .signal_i(btn_down_sync), .edge_o(btn_down_held_edge_rising)
  );
  btn_edge_detector #(
    .EDGE("FALLING")
  ) i_btn_edge_b_down_falling (
    .clk_i, .rst_ni, .clk_virt_i(end_of_frame),
    .signal_i(btn_down_sync), .edge_o(btn_down_held_edge_falling)
  );
  // button left
  btn_cdc i_btn_cdc_b_left (
    .clk_i, .rst_ni,
    .btn_i(btn_left_i), .btn_o(btn_left_sync)
  );
  btn_edge_detector #(
    .EDGE("RISING")
  ) i_btn_edge_b_left_rising (
    .clk_i, .rst_ni, .clk_virt_i(end_of_frame),
    .signal_i(btn_left_sync), .edge_o(btn_left_held_edge_rising)
  );
  btn_edge_detector #(
    .EDGE("FALLING")
  ) i_btn_edge_b_left_falling (
    .clk_i, .rst_ni, .clk_virt_i(end_of_frame),
    .signal_i(btn_left_sync), .edge_o(btn_left_held_edge_falling)
  );
  // button right
  btn_cdc i_btn_cdc_b_right (
    .clk_i, .rst_ni,
    .btn_i(btn_right_i), .btn_o(btn_right_sync)
  );
  btn_edge_detector #(
    .EDGE("RISING")
  ) i_btn_edge_b_right_rising (
    .clk_i, .rst_ni, .clk_virt_i(end_of_frame),
    .signal_i(btn_right_sync), .edge_o(btn_right_held_edge_rising)
  );
  btn_edge_detector #(
    .EDGE("FALLING")
  ) i_btn_edge_b_right_falling (
    .clk_i, .rst_ni, .clk_virt_i(end_of_frame),
    .signal_i(btn_right_sync), .edge_o(btn_right_held_edge_falling)
  );
  // button action
  btn_cdc i_btn_cdc_b_action (
    .clk_i, .rst_ni,
    .btn_i(btn_action_i), .btn_o(btn_action_sync)
  );
  btn_edge_detector #(
    .EDGE("RISING")
  ) i_btn_edge_b_action_rising (
    .clk_i, .rst_ni, .clk_virt_i(end_of_frame),
    .signal_i(btn_action_sync), .edge_o(btn_action_held_edge_rising)
  );
  btn_edge_detector #(
    .EDGE("FALLING")
  ) i_btn_edge_b_action_falling (
    .clk_i, .rst_ni, .clk_virt_i(end_of_frame),
    .signal_i(btn_action_sync), .edge_o(btn_action_held_edge_falling)
  );


endmodule