
module alien #(
    parameter logic [15:0] INITIAL_POSITION_X = 0,
    parameter logic [15:0] INITIAL_POSITION_Y = 0,
    parameter logic [15:0] MAX_POSITION_X = 640,
    parameter logic [15:0] SCALING = 4
) (
    input logic clk,
    input logic rst_n,

    input logic alive,
    input logic [15:0] movement_frequency,
    input logic movement_direction, // 0 = left, 1 = right
    input logic [15:0] movement_width,
    input logic armed, // 0 = unable to fire, 1 = capable of firing

    input logic [15:0] scan_x,
    input logic [15:0] scan_y,

    output logic graphics,
    output logic movement,
    output logic [15:0] current_position_x,
    output logic [15:0] current_position_y
);

  // internal signals for next state
  logic [15:0] position_x = INITIAL_POSITION_X;
  logic [15:0] position_y = INITIAL_POSITION_Y;
  logic [15:0] next_position_x;
  logic [15:0] next_position_y;

  // movement counter for frequency control
  logic [15:0] movement_counter;

  // output current positions
  assign current_position_x = position_x;
  assign current_position_y = position_y;

  // sprite ROM
localparam logic [15:0] sprite_width = 16;
localparam logic [15:0] sprite_height = 16;
logic [sprite_width-1:0] sprite_rom [0:sprite_height-1];
initial begin
    $readmemb("src/rtl/basic_alien.hex", sprite_rom);
end

// calculate relative position within sprite
logic signed [15:0] rel_x, rel_y;
logic in_sprite_bounds;

always_comb begin
    rel_x = (scan_x - position_x) / SCALING;
    rel_y = (scan_y - position_y) / SCALING;

    // check if current scan position is within sprite bounds
    in_sprite_bounds = (rel_x >= 0) && (rel_x < sprite_width) &&
                       (rel_y >= 0) && (rel_y < sprite_height) &&
                       alive;

    // output graphics signal based on sprite ROM
    graphics = in_sprite_bounds ? ~sprite_rom[rel_y[3:0]][rel_x[3:0]] : 1'b0;
end

  // combinational logic for movement calculation
  always_comb begin
    // default assignments to prevent latches
    next_position_x = position_x;
    next_position_y = position_y;

    // move when counter reaches frequency threshold
    if (movement_counter >= movement_frequency && alive) begin
        if (movement_direction) begin
            next_position_x = position_x + movement_width;
        end else begin
            next_position_x = position_x - movement_width;
        end
    end

    movement = alive &&
               (movement_counter >= movement_frequency) &&
               (next_position_x+(sprite_width*SCALING) >= MAX_POSITION_X || next_position_x == 0);
  end

  // sequential logic for state updates
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      position_x <= INITIAL_POSITION_X;
      position_y <= INITIAL_POSITION_Y;
      movement_counter <= 0;
    end else begin
      position_x <= next_position_x;
      position_y <= next_position_y;
      // update movement counter
      if (movement_counter >= movement_frequency) begin
        movement_counter <= 0;
      end else begin
        movement_counter <= movement_counter + 1;
      end

    end
  end

endmodule
