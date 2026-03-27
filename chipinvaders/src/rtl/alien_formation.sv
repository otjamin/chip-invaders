module alien_formation #(
    parameter logic [15:0] NUMBER_ROWS = 2,
    parameter logic [15:0] NUMBER_COLUMNS = 4,
    parameter logic [15:0] SPRITE_WIDTH = 16,
    parameter logic [15:0] SPRITE_HEIGHT = 16,
    parameter logic [15:0] SCALING_FACTOR = 2,
    parameter logic [15:0] ALIEN_SPACING_X = 20 * SCALING_FACTOR,
    parameter logic [15:0] ALIEN_SPACING_Y = 20 * SCALING_FACTOR,
    parameter logic [15:0] INITIAL_POSITION_X = 50,
    parameter logic [15:0] INITIAL_POSITION_Y = 50,
    parameter logic [15:0] MAX_POSITION_X = 640,
    parameter logic [15:0] MAX_POSITION_Y = 480
) (
    input logic clk,
    input logic rst_n,
    input logic enable,

    // current scan position of VGA module
    input logic [15:0] scan_x,
    input logic [15:0] scan_y,

    input logic [NUMBER_ROWS-1:0][NUMBER_COLUMNS-1:0] hit_matrix,

    // matrices representing individual alien status
    output logic [NUMBER_ROWS-1:0][NUMBER_COLUMNS-1:0] alive_matrix = '1,
    output logic [NUMBER_ROWS-1:0][NUMBER_COLUMNS-1:0][15:0] alien_position_x_matrix,
    output logic [NUMBER_ROWS-1:0][NUMBER_COLUMNS-1:0][15:0] alien_position_y_matrix,
    output logic alien_pixel
);

  //logic [3:0] level;
  logic [15:0] movement_frequency = 1;
  logic [7:0] alive_count;
  logic movement_direction_x = 1;
  logic movement_direction_y = 0;
  logic [15:0] movement_width;
  logic frozen = 0;
  logic [NUMBER_ROWS-1:0][NUMBER_COLUMNS-1:0][4:0] hitpoint_matrix;
  logic [NUMBER_ROWS-1:0][NUMBER_COLUMNS-1:0] armed_matrix;
  logic [NUMBER_ROWS-1:0][NUMBER_COLUMNS-1:0] graphics_matrix;
  logic [NUMBER_ROWS-1:0][NUMBER_COLUMNS-1:0] movement_matrix;
  logic [NUMBER_ROWS-1:0][NUMBER_COLUMNS-1:0] bottom_matrix;

  // count alive aliens and set speed by adjusting step width
  always_comb begin
    alive_count = 0;
    for (int r = 0; r < NUMBER_ROWS; r++) begin
      for (int c = 0; c < NUMBER_COLUMNS; c++) begin
        if (alive_matrix[r][c]) alive_count = alive_count + 1;
      end
    end

    if (alive_count <= 5) begin
      movement_width = 6;
    end else if (alive_count <= 10) begin
      movement_width = 5;
    end else if (alive_count <= 20) begin
      movement_width = 4;
    end else if (alive_count <= 30) begin
      movement_width = 3;
    end else begin
      movement_width = 2;
    end
  end

  // update armed-matrix based on alive-matrix
  always_comb begin
    for (int active_column = 0; active_column < NUMBER_COLUMNS; active_column++) begin
      for (int active_row = 0; active_row < NUMBER_ROWS; active_row++) begin
        armed_matrix[active_row][active_column] = alive_matrix[active_row][active_column];
        for (int lower_row = active_row + 1; lower_row < NUMBER_ROWS; lower_row++) begin
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
    for (row = 0; row < NUMBER_ROWS; row++) begin : g_alien_rows
      for (column = 0; column < NUMBER_COLUMNS; column++) begin : g_alien_cols

        // calculate initial position for each alien
        localparam logic [15:0] InitialPositionX = INITIAL_POSITION_X + (column * ALIEN_SPACING_X);
        localparam logic [15:0] InitialPositionY = INITIAL_POSITION_Y + (row * ALIEN_SPACING_Y);

        // create aliens
        alien #(
            .INITIAL_POSITION_X(InitialPositionX),
            .INITIAL_POSITION_Y(InitialPositionY),
            .MAX_POSITION_X(MAX_POSITION_X),
            .MAX_POSITION_Y(MAX_POSITION_Y),
            .SCALING_FACTOR(SCALING_FACTOR),
            .ALIEN_CLASS((row < 2) ? 4'b0001 : 4'b0),
            .SPRITE_WIDTH(SPRITE_WIDTH),
            .SPRITE_HEIGHT(SPRITE_HEIGHT)
        ) alien_inst (
            .clk(clk),
            .rst_n(rst_n),
            .enable(enable),
            .alive(alive_matrix[row][column]),
            .hit_registered(hit_matrix[row][column]),
            .movement_frequency(movement_frequency),
            .movement_width(movement_width),
            .movement_direction_x(movement_direction_x),
            .movement_direction_y(movement_direction_y),
            .armed(armed_matrix[row][column]),
            .frozen(frozen),
            .scan_x(scan_x),
            .scan_y(scan_y),
            .graphics(graphics_matrix[row][column]),
            .invert_movement(movement_matrix[row][column]),
            .reached_bottom(bottom_matrix[row][column]),
            .current_position_x(alien_position_x_matrix[row][column]),
            .current_position_y(alien_position_y_matrix[row][column]),
            .hitpoints_out(hitpoint_matrix[row][column])
        );

      end
    end
  endgenerate

  // combine alien graphics into single output bit
  always_comb begin
    alien_pixel = |graphics_matrix;
  end

  // update movement direction based on movement_matrix
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      movement_direction_x <= 1;
      movement_direction_y <= 0;
      frozen <= 0;
    end else if (enable) begin
      if (|movement_matrix) begin
        movement_direction_x <= ~movement_direction_x;
        movement_direction_y <= 1;
      end else begin
        movement_direction_y <= 0;
      end

      // freeze all aliens when any reaches bottom
      if (|bottom_matrix) begin
        frozen <= 1;
      end
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      //level <= 0;
      // initialize elements of matrix
      for (int r = 0; r < NUMBER_ROWS; r++) begin
        for (int c = 0; c < NUMBER_COLUMNS; c++) begin
          alive_matrix[r][c] <= 1'b1;
        end
      end
    end else if (enable) begin
      //level <= 1;
      // remove hit aliens
      for (int r = 0; r < NUMBER_ROWS; r++) begin
        for (int c = 0; c < NUMBER_COLUMNS; c++) begin
          if (hitpoint_matrix[r][c] <= 0) begin
            alive_matrix[r][c] <= 1'b0;
          end
        end
      end
    end
  end

endmodule
