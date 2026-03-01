
module alien_formation #(
    parameter logic [15:0] NUM_ROWS = 2,
    parameter logic [15:0] NUM_COLUMNS = 4,
    parameter logic [15:0] SCALING = 2,
    parameter logic [15:0] ALIEN_SPACING_X = 20 * SCALING,
    parameter logic [15:0] ALIEN_SPACING_Y = 20 * SCALING,
    parameter logic [15:0] INITIAL_POSITION_X = 50,
    parameter logic [15:0] INITIAL_POSITION_Y = 50,
    parameter logic [15:0] MAX_POSITION_X = 640,
    parameter logic [15:0] MAX_POSITION_Y = 480
) (
    input logic clk,
    input logic rst_n,

    // current scan position of VGA module
    input logic [15:0] scan_x,
    input logic [15:0] scan_y,

    // matrices representing individual alien status
    output logic [NUM_ROWS-1:0][NUM_COLUMNS-1:0] alive_matrix = '1,
    output logic alien_pixel
);

  logic [3:0] level;
  logic [15:0] movement_frequency = 1;
  logic movement_direction = 1;
  logic [15:0] movement_width = 1;
  logic [NUM_ROWS-1:0][NUM_COLUMNS-1:0] armed_matrix;
  logic [NUM_ROWS-1:0][NUM_COLUMNS-1:0] graphics_matrix;
  logic [NUM_ROWS-1:0][NUM_COLUMNS-1:0] movement_matrix;

  // update armed-matrix based on alive-matrix
  always_comb begin
    for (int active_column = 0; active_column < NUM_COLUMNS; active_column++) begin
      for (int active_row = 0; active_row < NUM_ROWS; active_row++) begin
        armed_matrix[active_row][active_column] = alive_matrix[active_row][active_column];
        for (int lower_row = active_row + 1; lower_row < NUM_ROWS; lower_row++) begin
          if (alive_matrix[lower_row][active_column]) begin
            armed_matrix[active_row][active_column] = 1'b0;
          end
        end
      end
    end
  end

  // create alien-matrix
  genvar row, column;
  generate
    for (row = 0; row < NUM_ROWS; row++) begin : g_alien_rows
      for (column = 0; column < NUM_COLUMNS; column++) begin : g_alien_cols

        // calculate initial position for each alien
        localparam logic [15:0] InitialPositionX = INITIAL_POSITION_X + (column * ALIEN_SPACING_X);
        localparam logic [15:0] InitialPositionY = INITIAL_POSITION_Y + (row * ALIEN_SPACING_Y);

        // create aliens
        alien #(
            .INITIAL_POSITION_X(InitialPositionX),
            .INITIAL_POSITION_Y(InitialPositionY),
            .MAX_POSITION_X(MAX_POSITION_X),
            .SCALING(SCALING)
        ) alien_inst (
            .clk(clk),
            .rst_n(rst_n),
            .alive(alive_matrix[row][column]),
            .movement_frequency(movement_frequency),
            .movement_width(movement_width),
            .movement_direction(movement_direction),
            .armed(armed_matrix[row][column]),
            .scan_x(scan_x),
            .scan_y(scan_y),
            .graphics(graphics_matrix[row][column]),
            .movement(movement_matrix[row][column])
        );

      end
    end
  endgenerate

  // Combine all alien graphics into single output bit
  always_comb begin
    alien_pixel = |graphics_matrix;
  end

  // Update movement direction based on movement_matrix
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      movement_direction <= 1;
    end else begin
      if (|movement_matrix) begin
        movement_direction <= ~movement_direction;
      end
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      level <= 0;
      alive_matrix <= '1;
    end else begin
      level <= 1;
      // basic level management
    end
  end

endmodule
