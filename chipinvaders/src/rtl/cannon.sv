`default_nettype none

module cannon #(
    parameter logic [9:0] SHIP_Y = 10'd440,
    parameter logic [9:0] SHIP_X = 10'd312
) (
    input  logic       rst_n,
    input  logic       v_sync,
    input  logic [9:0] pix_x,
    input  logic [9:0] pix_y,
    input  logic       move_left,
    input  logic       move_right,
    input logic fire,
    input  logic [3:0] scale,       // Scaling factor (1, 2, 4, etc.)
    output logic [9:0] cannon_x_pos,  // Current X position for bullet spawning
    output logic       cannon_graphics      // Pixel output signal for the VGA mixer
);

  localparam logic [9:0] BaseWidth = 16;
  localparam logic [9:0] BaseHeight = 16;
  localparam logic [9:0] Speed = 10'd4;

  // Logic to calculate current scaled size
  logic [9:0] scaled_width;
  logic [9:0] scaled_height;

  assign scaled_width  = BaseWidth * scale;
  assign scaled_height = BaseHeight * scale;

  logic [9:0] x_reg = SHIP_X;

  // --- MOVEMENT LOGIC ---
  // Update position on every Vertical Sync (once per frame)
  always_ff @(posedge v_sync or negedge rst_n) begin
    if (~rst_n) begin
      x_reg <= SHIP_X;  // Start at center screen
    end else begin
      if (move_left && x_reg > Speed) x_reg <= x_reg - Speed;
      else if (move_right && x_reg < (10'd640 - scaled_width)) x_reg <= x_reg + Speed;
    end
  end

  assign cannon_x_pos = x_reg;

  // --- SPRITE ROM ---
  localparam int SPRITE_W = 16;
  localparam int SPRITE_H = 16;

  logic [SPRITE_W-1:0] sprite_rom[0:SPRITE_H-1];
  initial begin
    $readmemb("src/rtl/single_barrel_cannon.hex", sprite_rom);
  end

  logic [SPRITE_W-1:0] sprite_rom_firing[0:SPRITE_H-1];
  initial begin
    $readmemb("src/rtl/single_barrel_cannon_fire.hex", sprite_rom_firing);
  end

  // --- RENDERING LOGIC ---
  logic signed [10:0] rel_x, rel_y;
  logic in_sprite_bounds;

  always_comb begin
    rel_x = (10'(pix_x) - x_reg) / scale;
    rel_y = (10'(pix_y) - SHIP_Y) / scale;

    in_sprite_bounds = (rel_x >= 0) && (rel_x < SPRITE_W) && (rel_y >= 0) && (rel_y < SPRITE_H);

    // rel_y[3:0] statt [2:0] - brauchen 4 Bit für Index 0-15
    if (fire) begin
      cannon_graphics = in_sprite_bounds ? ~sprite_rom_firing[rel_y[3:0]][SPRITE_W-1-rel_x[3:0]] : 1'b0;
    end else begin
      cannon_graphics = in_sprite_bounds ? ~sprite_rom[rel_y[3:0]][SPRITE_W-1-rel_x[3:0]] : 1'b0;
    end
  end

endmodule
