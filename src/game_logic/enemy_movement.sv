
`include "ff_macros.svh"

// Module to calculate the next position for the ghost.
// Two randomized triangle waves are summed for the Y axis.
// On rerandomize:
//   - wave amplitude  = 7 bits from LFSR (0-127 per wave, combined max ±254px)
//   - wave step       = 2 bits from LFSR + 1  (1-4, larger = faster)
//   - X position      = reset to 0 (enemy re-enters from left)
// Y center is fixed at screen center (240) so the enemy stays mostly on-screen.
// With combined max deviation ±254px from 240, the clamp at [0,479] triggers
// for at most 14px of overshoot — briefly visible at the very slowest speed.

module enemy_movement
  import game_logic_pkg::*;
(
    input logic clk_i,
    input logic rst_ni,

    // This is used as a time signal (virtual clk)
    input logic clk_virt_i,
    input game_pos_t rst_position_i,
    input logic rtl_i,

    // Random inputs latched on rerandomize
    input logic [15:0] rnd_0_i,
    input logic [15:0] rnd_1_i,
    input logic rerandomize_i,
    input logic freeze_i,

    // Output the position of the ghost
    output game_pos_t enemy_position_o
);

  localparam game_coord_t ENEMY_Y_CENTER = 240;   // Fixed vertical center (screen midpoint)
  localparam game_coord_t MOVEMENT_SPEED = 3;

  game_pos_t pos_d, pos_q;

  //////////////////////////////////////////////
  // Deferred rerandomize                     //
  // If rerandomize_i arrives while frozen,   //
  // latch it and fire when freeze lifts.     //
  //////////////////////////////////////////////
  logic rerandomize_pending_q;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rerandomize_pending_q <= 1'b0;
    end else begin
      if (rerandomize_i && freeze_i)
        rerandomize_pending_q <= 1'b1;
      else if (!freeze_i)
        rerandomize_pending_q <= 1'b0;
    end
  end

  // Fires the cycle freeze drops (deferred) or immediately when not frozen
  logic do_rerandomize;
  assign do_rerandomize = (rerandomize_i || rerandomize_pending_q) && !freeze_i;

  //////////////////////////////////////////////
  // Registered wave parameters               //
  //   rnd_0: [6:0]  wave1 amplitude (7-bit)  //
  //          [8:7]  wave1 step (2-bit)        //
  //   rnd_1: [6:0]  wave2 amplitude (7-bit)  //
  //          [8:7]  wave2 step (2-bit)        //
  //////////////////////////////////////////////
  game_coord_t wave1_amp_q,  wave2_amp_q;
  game_coord_t wave1_step_q, wave2_step_q;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      wave1_amp_q  <= game_coord_t'(15);
      wave1_step_q <= game_coord_t'(1);
      wave2_amp_q  <= game_coord_t'(10);
      wave2_step_q <= game_coord_t'(2);
    end else if (do_rerandomize) begin
      wave1_amp_q  <= game_coord_t'(rnd_0_i[6:0]);                        // 7-bit → 0..127
      wave1_step_q <= game_coord_t'(rnd_0_i[8:7]) + game_coord_t'(1);    // 2-bit → 1..4
      wave2_amp_q  <= game_coord_t'(rnd_1_i[6:0]);                        // 7-bit → 0..127
      wave2_step_q <= game_coord_t'(rnd_1_i[8:7]) + game_coord_t'(1);    // 2-bit → 1..4
    end
  end

  // Position register: reset X to 0 on rerandomize so enemy re-enters from left
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      pos_q <= rst_position_i;
    end else if (do_rerandomize) begin
      pos_q <= '{x: '0, y: ENEMY_Y_CENTER};
    end else if (clk_virt_i) begin
      pos_q <= pos_d;
    end
  end

  //////////////////////////////////////////////
  // Wave generators                          //
  //////////////////////////////////////////////
  game_coord_t wave1_val, wave2_val;
  logic wave1_is_negative, wave2_is_negative;

  triangle_wave_gen i_wave1 (
    .clk_i, .rst_ni, .clk_virt_i,
    .counter_top   (wave1_amp_q),
    .step_i        (wave1_step_q),
    .rerandomize_i (do_rerandomize),
    .wave_o        (wave1_val),
    .is_negative_o (wave1_is_negative)
  );

  triangle_wave_gen i_wave2 (
    .clk_i, .rst_ni, .clk_virt_i,
    .counter_top   (wave2_amp_q),
    .step_i        (wave2_step_q),
    .rerandomize_i (do_rerandomize),
    .wave_o        (wave2_val),
    .is_negative_o (wave2_is_negative)
  );

  //////////////////////////////////////////////
  // Position calculation                     //
  // y_signed range: [240-254, 240+254]       //
  //               = [-14, 494]               //
  // Clamp to [0, 479]: triggers for ≤14px    //
  //////////////////////////////////////////////
  always_comb begin
    logic signed [11:0] dev1, dev2, total_dev, y_signed;

    dev1      = wave1_is_negative ? -$signed({2'b0, wave1_val}) : $signed({2'b0, wave1_val});
    dev2      = wave2_is_negative ? -$signed({2'b0, wave2_val}) : $signed({2'b0, wave2_val});
    total_dev = dev1 + dev2;
    y_signed  = $signed({2'b0, ENEMY_Y_CENTER}) + total_dev;

    if(freeze_i) begin
      pos_d = pos_q;
    end else begin
      pos_d.x = pos_q.x + MOVEMENT_SPEED;
      pos_d.y = y_signed[11] ? 10'd0
              : (y_signed[10:0] > 11'd479 ? 10'd479 : y_signed[9:0]);
    end
  end

  assign enemy_position_o = pos_q;

endmodule
