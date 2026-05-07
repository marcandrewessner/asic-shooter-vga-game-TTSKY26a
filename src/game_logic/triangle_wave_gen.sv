
`include "ff_macros.svh"

// This creates a waveform generator
// it counts up to the top and then down
// note that the counter top is the amplitude,
// higher amplitude is slower

module triangle_wave_gen
  import game_logic_pkg::*;
#(
)
(
  input logic clk_i,
  input logic rst_ni,
  input logic clk_virt_i,

  input game_coord_t counter_top,
  input game_coord_t step_i,       // Advance wave counter by this amount per frame
  input logic rerandomize_i,       // Sync-reset phase and counter

  output game_coord_t wave_o,
  output logic is_negative_o
);

  logic [1:0] phase_d, phase_q;
  game_coord_t wave_cnt_d, wave_cnt_q;

  always_comb begin
    logic hit_top;
    if (counter_top == 0 || step_i == 0) begin
      hit_top    = 1'b0;
      wave_cnt_d = '0;
      phase_d    = phase_q;
    end else begin
      hit_top    = (wave_cnt_q + step_i >= counter_top);
      wave_cnt_d = hit_top ? game_coord_t'(0) : wave_cnt_q + step_i;
      phase_d    = phase_q + 2'(hit_top);
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      phase_q    <= 2'b0;
      wave_cnt_q <= '0;
    end else if (rerandomize_i) begin
      // Keep phase — resetting both to 0 would re-sync the two wave generators.
      // Only reset the counter so the new amplitude/step takes effect cleanly.
      wave_cnt_q <= '0;
    end else if (clk_virt_i) begin
      phase_q    <= phase_d;
      wave_cnt_q <= wave_cnt_d;
    end
  end

  assign is_negative_o = phase_q==2 || phase_q==3;
  always_comb begin
    logic is_running_down;
    is_running_down = phase_q==1 || phase_q==3;

    if (counter_top == 0)
      wave_o = '0;
    else if (is_running_down)
      wave_o = counter_top - wave_cnt_q;
    else
      wave_o = wave_cnt_q;
  end

endmodule
