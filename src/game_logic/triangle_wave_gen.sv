
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

  output game_coord_t wave_o,
  output logic is_negative_o
);

  logic [1:0] phase_d, phase_q;
  game_coord_t wave_cnt_d, wave_cnt_q;

  always_comb begin
    wave_cnt_d = (wave_cnt_q>=counter_top) ? 0 : wave_cnt_q+1;
    phase_d = phase_q + (wave_cnt_q==counter_top);
  end

  `FFAR_EN(clk_i, rst_ni, 0, phase_q, phase_d, clk_virt_i);
  `FFAR_EN(clk_i, rst_ni, 0, wave_cnt_q, wave_cnt_d, clk_virt_i);

  assign is_negative_o = phase_q==2 || phase_q==3;
  always_comb begin
    logic is_running_down;
    is_running_down = phase_q==1 || phase_q==3;
    
    if(is_running_down)
      wave_o = counter_top - wave_cnt_q;
    else
      wave_o = wave_cnt_q;
  end

endmodule
