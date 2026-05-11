// Stub for RTL simulation — the real design is in project.sv (SystemVerilog).
// This file satisfies the cocotb Makefile dependency for the RTL sim path.
module tt_um_maw_game (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);
  assign uo_out  = 8'b0;
  assign uio_out = 8'b0;
  assign uio_oe  = 8'b0;
endmodule
