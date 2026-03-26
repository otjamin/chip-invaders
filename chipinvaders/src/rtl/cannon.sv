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
    input  logic [3:0] scale,           // Scaling factor (1, 2, 4, etc.)
    output logic [9:0] cannon_x_pos,    // Current X position for bullet spawning
    output logic       cannon_graphics  // Pixel output signal for the VGA mixer
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

  cannon_display #(
      .CANNON_Y(SHIP_Y)
  ) display (
      .pix_x(pix_x),
      .pix_y(pix_y),
      .scale(scale),
      .x_reg(x_reg),
      .cannon_graphics(cannon_graphics)
  );

endmodule
