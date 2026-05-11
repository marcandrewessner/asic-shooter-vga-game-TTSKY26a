
module bird_animated
  import graphics_engine_pkg::*;
  import graphics_rom_pkg::*;
#(
  parameter int FRAMES_P_STATE = 10
) (
  input logic clk_i,
  input logic rst_ni,
  input logic end_of_frame,

  input sprite_input_t sprite_input,
  output sprite_output_t sprite_output
);

  ////////////////////////////////////
  // ANIMATION FSM //
  ////////////////////////////////////
  int animation_frame_d, animation_frame_q;
  int frame_counter_d, frame_counter_q;

  always_comb begin
    frame_counter_d = frame_counter_q + 1;
    animation_frame_d = animation_frame_q;
    // wrap around the frame counter
    if(frame_counter_q==FRAMES_P_STATE) begin
      frame_counter_d = '0;
      animation_frame_d = (animation_frame_q=='d4) ? '0 : animation_frame_q+1;
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
      frame_counter_q <= '0;
      animation_frame_q <= '0;
    end
    if(end_of_frame) begin
      frame_counter_q <= frame_counter_d;
      animation_frame_q <= animation_frame_d;
    end
  end

  ////////////////////////////////////
  // Instantiate the frames //
  ////////////////////////////////////
  sprite_output_t bird_0_output;
  sprite_output_t bird_1_output;
  sprite_output_t bird_2_output;
  sprite_output_t bird_3_output;
  sprite_output_t bird_4_output;

  bird_0_sprite i_bird_0_sprite (
    .clk_i, .rst_ni,
    .sprite_input,
    .sprite_output(bird_0_output)
  );
  bird_1_sprite i_bird_1_sprite (
    .clk_i, .rst_ni,
    .sprite_input,
    .sprite_output(bird_1_output)
  );
  bird_2_sprite i_bird_2_sprite (
    .clk_i, .rst_ni,
    .sprite_input,
    .sprite_output(bird_2_output)
  );
  bird_3_sprite i_bird_3_sprite (
    .clk_i, .rst_ni,
    .sprite_input,
    .sprite_output(bird_3_output)
  );
  bird_4_sprite i_bird_4_sprite (
    .clk_i, .rst_ni,
    .sprite_input,
    .sprite_output(bird_4_output)
  );


  ////////////////////////////////////
  // Select the right frame //
  ////////////////////////////////////
  argb_t color;
  always_comb begin
    case (animation_frame_q)
      'd0 : color = bird_0_output.color;
      'd1 : color = bird_1_output.color;
      'd2 : color = bird_2_output.color;
      'd3 : color = bird_3_output.color;
      'd4 : color = bird_4_output.color;
    endcase
  end 

  assign sprite_output.color = color ^ 4'b1000;

endmodule