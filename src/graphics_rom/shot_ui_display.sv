
// Use this module to display the misses
// on screen

module shot_ui_display import graphics_engine_pkg::*; #(
  // how many shots to display
  parameter int N_SHOTS = 10,
  // Define appearance
  parameter pix_coord_t ITEM_CENTER_DISTANCE = 'd30
) (
  input logic clk_i,
  input logic rst_ni,

  input pix_pos_t left_center_pos,
  input pix_pos_t vga_pos,

  input logic [N_SHOTS-1:0] shots_used_i,
  input logic [N_SHOTS-1:0] shots_hit_i,

  output argb_t color_o
);

  //////////////////////////////////////////////
  // build up the ui boxes //
  //////////////////////////////////////////////
  argb_t item_colors [N_SHOTS-1:0];

  generate
    for(genvar i=0; i<N_SHOTS; i++) begin : gen_ui_element
      
      localparam pix_coord_t item_center_x = i*ITEM_CENTER_DISTANCE;

      logic item_used, item_hit;

      // I want right to left for the display
      // thus we traverse from the other side
      assign item_used = shots_used_i[N_SHOTS-1-i];
      assign item_hit  = shots_hit_i[N_SHOTS-1-i];

      // Build up the item drawing
      pix_coord_t cx, cy, vx, vy;
      assign cx = left_center_pos.x + item_center_x;
      assign cy = left_center_pos.y;
      assign vx = vga_pos.x;
      assign vy = vga_pos.y;

      // Create the outer box
      localparam pix_coord_t OUTERBOX_WIDTH  = 10;
      localparam pix_coord_t OUTERBOX_HEIGHT = 15;
      logic outerbox_active;
      assign outerbox_active = (
        vx-OUTERBOX_WIDTH  < cx && cx < vx+OUTERBOX_WIDTH &&
        vy-OUTERBOX_HEIGHT < cy && cy < vy+OUTERBOX_HEIGHT
      );

      // Build up the color
      always_comb begin
        if(outerbox_active && !item_used)
          item_colors[i] = 4'b1111; // white
        else if(outerbox_active && item_used && item_hit)
          item_colors[i] = 4'b1010; // green
        else if(outerbox_active && item_used && !item_hit)
          item_colors[i] = 4'b1100; // red
        else
          item_colors[i] = 'b0;
      end
    
    end
  endgenerate

  //////////////////////////////////////////////
  // combine the colors together //
  //////////////////////////////////////////////
  always_comb begin
    color_o = 'b0;
    for(int i=0; i<N_SHOTS; i++)
      color_o = color_o | item_colors[i];
  end

endmodule