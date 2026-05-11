
// Use this module to display the misses
// on screen

module shot_ui_display
  import graphics_engine_pkg::*;
  import graphics_rom_pkg::*;
#(
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
      sprite_output_t bullet_sprite_output;
      sprite_input_t bullet_sprite_input;

      assign bullet_sprite_input = '{
        center_pix: '{
          x: left_center_pos.x + item_center_x,
          y: left_center_pos.y
        },
        vga_pos: vga_pos
      };

      bullet_sprite i_bullet_sprite (
        .clk_i, .rst_ni,
        .sprite_input(bullet_sprite_input),
        .sprite_output(bullet_sprite_output)
      );

      // Build up the output
      always_comb begin
        argb_t color;
        color = bullet_sprite_output.color ^ 4'b1000;
        // Allow switching colors
        if(color=='b1111 && item_used && item_hit)
          item_colors[i] = 4'b1010; // green
        else if(color=='b1111 && item_used && !item_hit)
          item_colors[i] = 4'b1100; // red
        else
          item_colors[i] = color;
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