

// This creates the game state FSM 
// to control the output of the game

`include "ff_macros.svh"

module game_state_fsm import game_logic_pkg::*; #(
  // Define how many shots can be retried
  parameter int N_SHOTS = 10
) (
  input clk_i,
  input rst_ni,

  // End of a frame has been reached
  input end_of_frame_i,
  input btn_action_edge_held_i,
  
  // Get the events happened (note this must be aligned to end of frame)
  input missed_i,
  input hit_i,
  
  output game_state_e game_state_o,

  // Give out the history of the used shots
  output logic [N_SHOTS-1:0] used_shots_o,
  output logic [N_SHOTS-1:0] score_shots_o  
);

  //////////////////////////////////////////////
  // define gamestate and a frame counter //
  //////////////////////////////////////////////
  logic [7:0] frame_counter_d, frame_counter_q; // can count 256 frames
  game_state_e game_state_d, game_state_q;

  `FFAR_EN(clk_i, rst_ni, '0, frame_counter_q, frame_counter_d, end_of_frame_i)
  `FFAR_EN(clk_i, rst_ni, GAME_STATE_RESET, game_state_q, game_state_d, end_of_frame_i)

  assign game_state_o = game_state_q;


  //////////////////////////////////////////////
  // define the shot history //
  //////////////////////////////////////////////
  logic [N_SHOTS-1:0] used_shots_d, used_shots_q;
  logic [N_SHOTS-1:0] score_shots_d, score_shots_q;

  `FFAR(clk_i, rst_ni, used_shots_q, used_shots_d, '0);
  `FFAR(clk_i, rst_ni, score_shots_q, score_shots_d, '0);

  assign used_shots_o  = used_shots_q;
  assign score_shots_o = score_shots_q;


  //////////////////////////////////////////////
  // define the FSM logic //
  //////////////////////////////////////////////

  always_comb begin : game_state_fsm_logic
    
    frame_counter_d = frame_counter_q;
    game_state_d = game_state_q;

    case (game_state_q)
      GAME_STATE_RESET: begin
        frame_counter_d = '0;
        game_state_d = GAME_STATE_START_SCREEN;
      end
      GAME_STATE_START_SCREEN: begin
        game_state_d = btn_action_edge_held_i ? GAME_STATE_SHOOTING : GAME_STATE_START_SCREEN;
      end
      GAME_STATE_SHOOTING: ;
      default: ;
    endcase
  end

endmodule