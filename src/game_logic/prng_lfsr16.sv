
module prng_lfsr16 (
    input  logic clk_i,
    input  logic rst_ni,
    output logic [15:0] rnd_o
);

  logic feedback;

  // Polynomial: x^16 + x^14 + x^13 + x^11 + 1
  assign feedback = rnd[15] ^ rnd[13] ^ rnd[12] ^ rnd[10];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      rnd <= 16'hACE1;   // nonzero seed
    else
      rnd <= {rnd[14:0], feedback};
  end

  assign rnd_o = rnd;

endmodule