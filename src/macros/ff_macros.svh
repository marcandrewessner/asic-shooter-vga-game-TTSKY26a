

`ifndef __SVH_FF_MACROS__
`define __SVH_FF_MACROS__

// Define TVSIMULATOR when targeting the TV simulator (30 FPS clock).
// Comment out for real hardware, which runs at 60 FPS — the game_tick
// divider in main.sv halves the game-logic rate automatically so all
// movement speeds and delay timings stay identical.
`define TVSIMULATOR


// Basic FF macro
`define FFAR(_clk, _rst_n, _q, _d, _rst_val)        \
  always_ff @(posedge _clk or negedge _rst_n) begin \
    if(!_rst_n) begin                               \
      _q <= _rst_val;                               \
    end else begin                                  \
      _q <= _d;                                     \
    end                                             \
  end


// Basic FF macro but only do action
// if we have the enable high
`define FFAR_EN(_clk, _rst_n, _rst_val, _q, _d, _en)  \
  always_ff @(posedge _clk or negedge _rst_n) begin   \
    if(!_rst_n) begin                                 \
      _q <= _rst_val;                                 \
    end else if (_en) begin                           \
      _q <= _d;                                       \
    end                                               \
  end

`endif
