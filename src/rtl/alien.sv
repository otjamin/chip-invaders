module alien #(
    parameter logic [15:0] SPRITE_WIDTH = 16,
    parameter logic [15:0] SPRITE_HEIGHT = 16,
    parameter logic [15:0] INITIAL_POSITION_X = 0,
    parameter logic [15:0] INITIAL_POSITION_Y = 0,
    parameter logic [15:0] MAX_POSITION_X = 640,
    parameter logic [15:0] MAX_POSITION_Y = 480,
    parameter logic [15:0] SCALING_FACTOR = 2,
    parameter logic [3:0] ALIEN_CLASS = 0
) (
    input logic clk,
    input logic rst_n,
    input logic enable,

    input logic alive,
    input logic hit_registered,
    input logic [15:0] movement_frequency,
    input logic movement_direction_x,  // 0 = left, 1 = right
    input logic movement_direction_y,  // 0 = stay, 1 = down
    input logic [15:0] movement_width,
    input logic armed,  // 0 = unable to fire, 1 = capable of firing
    input logic frozen,  // 0 = moving, 1 = frozen

    input logic [15:0] scan_x,
    input logic [15:0] scan_y,

    output logic graphics,
    output logic invert_movement,
    output logic reached_bottom,
    output logic [15:0] current_position_x,
    output logic [15:0] current_position_y,
    output logic [4:0] hitpoints_out
);

  // internal signals for next state
  logic [15:0] position_x = INITIAL_POSITION_X;
  logic [15:0] position_y = INITIAL_POSITION_Y;
  logic [15:0] next_position_x;
  logic [15:0] next_position_y;
  logic [ 4:0] hitpoints = (ALIEN_CLASS == 1) ? 2 : 1;

  // invert_movement counter for frequency control
  logic [15:0] movement_counter;

  // output current positions
  assign current_position_x = position_x;
  assign current_position_y = position_y;
  assign hitpoints_out = hitpoints;

  // sprite ROM
  logic [SPRITE_WIDTH-1:0] sprite_rom[SPRITE_HEIGHT];
  initial begin
    if (ALIEN_CLASS == 1) begin
      $readmemb("src/rtl/simple_alien.hex", sprite_rom);
    end else begin
      $readmemb("src/rtl/basic_alien.hex", sprite_rom);
    end
  end

  // calculate relative position within sprite
  logic signed [15:0] rel_x, rel_y;
  logic in_sprite_bounds;

  always_comb begin
    rel_x = (scan_x - position_x) / SCALING_FACTOR;
    rel_y = (scan_y - position_y) / SCALING_FACTOR;

    // check if current scan position is within sprite bounds
    in_sprite_bounds = (rel_x >= 0) && (rel_x < SPRITE_WIDTH) &&
                       (rel_y >= 0) && (rel_y < SPRITE_HEIGHT) &&
                       alive;

    // output graphics signal based on sprite ROM
    graphics = in_sprite_bounds ? ~sprite_rom[rel_y[3:0]][rel_x[3:0]] : 1'b0;
  end

  // combinational logic for invert_movement calculation
  always_comb begin
    // default assignments to prevent latches
    next_position_x = position_x;
    next_position_y = position_y;

    // move when counter reaches frequency threshold and not frozen
    if (movement_counter >= movement_frequency && alive && !frozen) begin
      if (movement_direction_x) begin
        next_position_x = position_x + movement_width;
      end else begin
        if (position_x >= movement_width) begin
          next_position_x = position_x - movement_width;
        end else begin
          next_position_x = 0;
        end
      end
    end

    // move down when direction_y is set and not frozen
    if (movement_direction_y && alive && !frozen) begin
      next_position_y = position_y + (SPRITE_HEIGHT * SCALING_FACTOR);
    end

    invert_movement = alive && !frozen &&
               (movement_counter >= movement_frequency) &&
               (next_position_x+(SPRITE_WIDTH*SCALING_FACTOR) >= MAX_POSITION_X || 
                next_position_x < movement_width);

    reached_bottom = alive && (position_y + (SPRITE_HEIGHT * SCALING_FACTOR) >= MAX_POSITION_Y);
  end

  // sequential logic for state updates
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      position_x <= INITIAL_POSITION_X;
      position_y <= INITIAL_POSITION_Y;
      movement_counter <= 0;
      hitpoints <= (ALIEN_CLASS == 1) ? 2 : 1;
    end else if (enable) begin
      position_x <= next_position_x;
      position_y <= next_position_y;
      if (hit_registered && alive && hitpoints > 0) begin
        hitpoints <= hitpoints - 1;
      end
      // update movement counter
      if (movement_counter >= movement_frequency) begin
        movement_counter <= 0;
      end else begin
        movement_counter <= movement_counter + 1;
      end

    end
  end

endmodule
