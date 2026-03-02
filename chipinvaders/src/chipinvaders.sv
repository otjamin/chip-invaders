module chipinvaders (
    input logic clk,
    input logic rst_n,

    // Buttons
    //input logic btn_d,
    input logic btn_l,
    input logic btn_r,
    input logic btn_u,

    // VGA
    output logic [3:0] vga_r,
    output logic [3:0] vga_g,
    output logic [3:0] vga_b,
    output logic vga_hs,
    output logic vga_vs
);
  // Generate a 25 MHz clock from the 100 MHz input
  logic [1:0] counter;
  logic clk_25mhz;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      counter <= 0;
    end else begin
      counter <= counter + 1;
    end
  end

  assign clk_25mhz = counter[1];
  //assign clk_25mhz = clk;

  // Colors
  localparam logic [11:0] CannonColor = 12'b0100_1001_0000;
  localparam logic [11:0] LaserColor = 12'b1111_1001_0011;
  localparam logic [11:0] AlienColorA = 12'b0110_0110_1111;
  localparam logic [11:0] AlienColorB = 12'b1010_0110_1111;
  localparam logic [11:0] AlienColorC = 12'b1111_0110_1111;

  // VGA signals
  logic hsync;
  logic vsync;
  logic display_on;
  logic [9:0] hpos;
  logic [9:0] vpos;

  hvsync_generator hvsync_gen (
      .clk(clk_25mhz),
      .reset(~rst_n),
      .hsync(hsync),
      .vsync(vsync),
      .display_on(display_on),
      .hpos(hpos),
      .vpos(vpos)
  );

  // All game signals
  logic reset_game;
  logic [1:0] game_state;  // 00 = start, 01 = playing, 10 = game over

  logic [9:0] cannon_x;
  logic cannon_gfx;

  logic laser_active;
  logic [9:0] laser_x;
  logic [9:0] laser_y;
  logic laser_gfx;

  logic [1:0] lives = 3;
  logic [13:0] score;

// Alien formation
  localparam int number_rows = 5;
  localparam int number_columns = 8;
  logic [number_rows-1:0][number_columns-1:0] alive_matrix;
  logic [number_rows-1:0][number_columns-1:0] hit_matrix;
  logic [15:0] [number_rows-1:0][number_columns-1:0] alien_position_x_matrix;
  logic [15:0] [number_rows-1:0][number_columns-1:0] alien_position_y_matrix;
  logic alien_pixel;

  alien_formation #(
      .NUMBER_ROWS(number_rows),
      .NUMBER_COLUMNS(number_columns)
  ) aliens (
      .clk(vsync),
      .rst_n(rst_n),
      .scan_x(hpos),
      .scan_y(vpos),
      .alive_matrix(alive_matrix),
      .hit_matrix(hit_matrix),
      .alien_position_x_matrix(alien_position_x_matrix),
      .alien_position_y_matrix(alien_position_y_matrix),
      .alien_pixel(alien_pixel)
  );

  // Collision detection
  logic hit_alien;
  
  collision_detection #(
      .NUMBER_ROWS(number_rows),
      .NUMBER_COLUMNS(number_columns),
      .alien_sprite_width(16),
      .alien_sprite_height(16),
      .ALIEN_SCALING(2),
      .projectile_sprite_width(1),
      .projectile_sprite_height(4),
      .PROJECTILE_SCALING(4)
  ) collision_det (
      .clk(clk_25mhz),
      .rst_n(rst_n),
      .alive_matrix(alive_matrix),
      .alien_position_x_matrix(alien_position_x_matrix),
      .alien_position_y_matrix(alien_position_y_matrix),
      .laser_active(laser_active),
      .laser_position_x(laser_x),
      .laser_position_y(laser_y),
      .hit_matrix(hit_matrix)
  );

  // Detect if any alien was hit
  always_comb begin
    hit_alien = |hit_matrix;
  end

  // Cannon modules
  cannon cannon (
      .rst_n(rst_n),
      .v_sync(vsync),
      .pix_x(hpos),
      .pix_y(vpos),
      .move_left(btn_l),
      .move_right(btn_r),
      .fire(btn_u),
      .cannon_x_pos(cannon_x),
      .cannon_graphics(cannon_gfx),
      .scale(2)
  );

  cannon_laser #(
      .CANNON_Y(440)
  ) laser (
      .reset_n(rst_n),
      .vpos(vpos),
      .hpos(hpos),
      .vsync(vsync),
      .shoot(btn_u),
      .cannon_x(cannon_x),
      .hit_alien(hit_alien),
      .laser_active(laser_active),
      .laser_x(laser_x),
      .laser_y(laser_y),
      .laser_gfx(laser_gfx)
  );

  // Scoreboard and Lives
  logic hud_label_on;
  logic hud_value_on;

  always_ff @(posedge reset_game) begin
    lives <= 3;  // Reset to 3 lives at the start of the game
    score <= 0;
  end

  hud hud (
      .pix_x   (hpos),
      .pix_y   (vpos),
      .lives   (lives),
      .score   (score),
      .label_on(hud_label_on),
      .value_on(hud_value_on)
  );

  // Game Start and Game Over
  logic blink_signal;
  logic [1:0] disp_r;
  logic [1:0] disp_g;
  logic [1:0] disp_b;

  game_display game_disp (
      .rst_n(rst_n),
      .v_sync(vsync),
      .pix_x(hpos),
      .pix_y(vpos),
      .state(game_state),
      .blink_signal(blink_signal),
      .r(disp_r),
      .g(disp_g),
      .b(disp_b)
  );

  logic game_over_trigger = (lives == 0);

  game_state_machine state_machine (
      .rst_n(rst_n),
      .v_sync(vsync),
      .trigger_in(btn_u),
      .game_over_trigger(game_over_trigger),
      .state(game_state),
      .blink_signal(blink_signal),
      .reset_game(reset_game)
  );

  // RGB output logic
  always_comb begin
    vga_r = 0;
    vga_g = 0;
    vga_b = 0;
    if (display_on) begin
      if ((game_state == 2'b00) || (game_state == 2'b10)) begin
        vga_r = {disp_r, 2'b00};
        vga_g = {disp_g, 2'b00};
        vga_b = {disp_b, 2'b00};
      end else begin
        if (cannon_gfx) begin
          vga_r = CannonColor[11:8];
          vga_g = CannonColor[7:4];
          vga_b = CannonColor[3:0];
        end else if (laser_gfx) begin
          vga_r = LaserColor[11:8];
          vga_g = LaserColor[7:4];
          vga_b = LaserColor[3:0];
        end else if (alien_pixel) begin
          vga_r = AlienColorA[11:8];
          vga_g = AlienColorA[7:4];
          vga_b = AlienColorA[3:0];
        end else if (hud_label_on) begin
          vga_r = 4'b1111;
          vga_g = 4'b1111;
          vga_b = 4'b1111;
        end else if (hud_value_on) begin
          vga_r = CannonColor[11:8];
          vga_g = CannonColor[7:4];
          vga_b = CannonColor[3:0];
        end
      end
    end
  end

  assign vga_hs = hsync;
  assign vga_vs = vsync;

endmodule
