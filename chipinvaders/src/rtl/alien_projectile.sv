module alien_projectile #(
    parameter LOWER_BORDER = 480,
    parameter SCALING = 4
) (
    input logic clock,
    input logic reset_n,
    input logic enable,

    input logic [9:0] vpos,
    input logic [9:0] hpos,
    //input logic vsync,

    input logic shoot,
    input logic [9:0] alien_x,
    input logic [9:0] alien_y,

    input logic hit_cannon,

    output logic projectile_active,
    output logic [9:0] projectile_x,
    output logic [9:0] projectile_y,

    output logic projectile_gfx
);

  localparam ProjectileSpeed = 6;

  logic frame;

  always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
      projectile_active <= 0;
      frame <= 0;
    end else if (enable) begin
      if (shoot && !projectile_active) begin
        projectile_x <= alien_x;
        projectile_y <= alien_y;
        projectile_active <= 1;
        frame <= 0;
      end else if (projectile_active) begin
        projectile_y <= projectile_y + ProjectileSpeed;
        frame <= ~frame;
        if (projectile_y > LOWER_BORDER || hit_cannon) begin
          projectile_active <= 0;
        end
      end
    end
  end

  // TODO: Improve the gfx if possible
  logic [9:0] sx = (hpos - projectile_x) / SCALING;
  logic [9:0] sy = (vpos - projectile_y) / SCALING;

  logic in_sprite = projectile_active &&
                   (hpos >= projectile_x) && (sx < 3) &&
                   (vpos >= projectile_y) && (sy < 5);

  logic is_center_col = (sx == 1);
  logic is_bar_row = frame ? (sy == 1) : (sy == 3);

  assign projectile_gfx = in_sprite && (is_center_col || is_bar_row);

endmodule
