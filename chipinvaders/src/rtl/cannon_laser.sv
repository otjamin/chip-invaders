module cannon_laser #(
    parameter CANNON_Y = 470,
    parameter UPPER_BORDER = 100,
    parameter SCALING = 4
) (
    input logic reset_n,

    input logic [9:0] vpos,
    input logic [9:0] hpos,
    input logic vsync,

    input logic shoot,
    input logic [9:0] cannon_x,

    input logic hit_alien,

    output logic laser_active,
    output logic [9:0] laser_x,
    output logic [9:0] laser_y,

    output logic laser_gfx
);

  localparam LaserSpeed = 6;
  localparam LaserWidth = 1 * SCALING;
  localparam LaserHeight = 4  * SCALING;

  always_ff @(posedge vsync or negedge reset_n) begin
    if (!reset_n) begin
      laser_active <= 0;
    end else if (shoot && !laser_active) begin
      laser_x <= cannon_x+(6); // TODO: Center laser on cannon
      laser_y <= CANNON_Y;
      laser_active <= 1;
    end else if (laser_active) begin
      if (laser_y > UPPER_BORDER + LaserSpeed) begin
        laser_y <= laser_y - LaserSpeed;
      end else begin
        laser_active <= 0;
      end
      
      if (hit_alien) begin
        laser_active <= 0;
      end
    end
  end

  assign laser_gfx = laser_active &&
                     (hpos >= laser_x) && (hpos < laser_x + LaserWidth) &&
                     (vpos >= laser_y) && (vpos < laser_y + LaserHeight);

endmodule
