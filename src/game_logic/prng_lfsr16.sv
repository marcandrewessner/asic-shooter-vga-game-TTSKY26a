
module prng_lfsr16 #(
  parameter logic [15:0] SEED = 16'hACE1
) (
    input  logic clk_i,
    input  logic rst_ni,
    output logic [15:0] rnd_o
);

  logic [15:0] rnd;
  logic feedback;

  // Polynomial: x^16 + x^14 + x^13 + x^11 + 1
  assign feedback = rnd[15] ^ rnd[13] ^ rnd[12] ^ rnd[10];

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni)
      rnd <= SEED;   // nonzero seed
    else
      rnd <= {rnd[14:0], feedback};
  end

  assign rnd_o = rnd;

endmodule