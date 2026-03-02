
module collision_detection #(
    parameter logic [15:0] NUMBER_ROWS = 2,
    parameter logic [15:0] NUMBER_COLUMNS = 4,
    parameter logic [15:0] alien_sprite_width = 16,
    parameter logic [15:0] alien_sprite_height = 16,
    parameter int ALIEN_SCALING = 2,
    parameter logic [15:0] projectile_sprite_width = 1,
    parameter logic [15:0] projectile_sprite_height = 4,
    parameter int PROJECTILE_SCALING = 4
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

  logic [15:0] alien_width = alien_sprite_width * ALIEN_SCALING;
  logic [15:0] alien_height = alien_sprite_height * ALIEN_SCALING;
  logic [15:0] laser_width = projectile_sprite_width * PROJECTILE_SCALING;
  logic [15:0] laser_height = projectile_sprite_height * PROJECTILE_SCALING;

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
