module collision_detection #(
    parameter logic [15:0] NUMBER_ROWS = 2,
    parameter logic [15:0] NUMBER_COLUMNS = 4,
    parameter logic [15:0] ALIEN_SPRITE_WIDTH = 16,
    parameter logic [15:0] ALIEN_SPRITE_HEIGHT = 16,
    parameter logic [3:0] ALIEN_SCALING = 2,
    parameter logic [15:0] PROJECTILE_SPRITE_WIDTH = 1,
    parameter logic [15:0] PROJECTILE_SPRITE_HEIGHT = 4,
    parameter logic [3:0] PROJECTILE_SCALING = 4
) (
    input logic clk,
    input logic rst_n,

    input logic [NUMBER_ROWS-1:0][NUMBER_COLUMNS-1:0] alive_matrix,
    input logic [NUMBER_ROWS-1:0][NUMBER_COLUMNS-1:0][15:0] alien_position_x_matrix,
    input logic [NUMBER_ROWS-1:0][NUMBER_COLUMNS-1:0][15:0] alien_position_y_matrix,
    input logic laser_active,
    input logic [15:0] laser_position_x,
    input logic [15:0] laser_position_y,

    output logic [NUMBER_ROWS-1:0][NUMBER_COLUMNS-1:0] hit_matrix
);

  logic [15:0] alien_width = ALIEN_SPRITE_WIDTH * ALIEN_SCALING;
  logic [15:0] alien_height = ALIEN_SPRITE_HEIGHT * ALIEN_SCALING;
  logic [15:0] laser_width = PROJECTILE_SPRITE_WIDTH * PROJECTILE_SCALING;
  logic [15:0] laser_height = PROJECTILE_SPRITE_HEIGHT * PROJECTILE_SCALING;

  always_comb begin
    hit_matrix = '0;
    if (laser_active) begin
      for (int r = 0; r < NUMBER_ROWS; r++) begin
        for (int c = 0; c < NUMBER_COLUMNS; c++) begin
          // only check collision if alien is alive
          if (alive_matrix[r][c] &&
              (laser_position_x + laser_width > alien_position_x_matrix[r][c]) &&
              (laser_position_x < alien_position_x_matrix[r][c] + alien_width) &&
              (laser_position_y + laser_height > alien_position_y_matrix[r][c]) &&
              (laser_position_y < alien_position_y_matrix[r][c] + alien_height)) begin
            hit_matrix[r][c] = 1'b1;
          end
        end
      end
    end
  end

endmodule
