/**
 * Module: hud
 * Description: UI Head-Up Display for the game (Score and Lives).
 * This module receives screen coordinates and game state to output RGB signals.
 * You can change the colors, and need to give it coordinates, the lives and score, its just a hud that shows information on the screen
 * It also has a scaling variable
 */
module hud #(
    parameter logic [3:0] SCALE = 1
) (
    input  logic [ 9:0] pix_x,     // Current beam X position
    input  logic [ 9:0] pix_y,     // Current beam Y position
    input  logic [ 1:0] lives,     // Current player lives (0-3)
    input  logic [13:0] score,     // Current player score (0-9999)
    output logic        label_on,  // High when a "SCORE:" label pixel is active
    output logic        value_on   // High when a score digit or lives icon pixel is active
);

  localparam logic [9:0] HudYPos = 10'd20;
  localparam logic [9:0] ScoreXStart = 10'd40;
  localparam logic [9:0] LivesXStart = 10'd500;


  // static "SCORE"

  localparam logic [15:0] ScoreCharScaling = 3 * SCALE;
  localparam logic [15:0] ScoreCharW = 5;
  localparam logic [15:0] ScoreCharGap = 1;
  localparam logic [15:0] ScoreStep = (ScoreCharW + ScoreCharGap) * ScoreCharScaling;

  logic [4:0] label_on_matrix;

  character #(
      .SCALING(ScoreCharScaling),
      .X_POS  (ScoreXStart + 0 * ScoreStep),
      .Y_POS  (HudYPos)
  ) score_s (
      .hpos(pix_x),
      .vpos(pix_y),
      .char("S"),
      .graphics(label_on_matrix[0])
  );

  character #(
      .SCALING(ScoreCharScaling),
      .X_POS  (ScoreXStart + 1 * ScoreStep),
      .Y_POS  (HudYPos)
  ) score_c (
      .hpos(pix_x),
      .vpos(pix_y),
      .char("C"),
      .graphics(label_on_matrix[1])
  );

  character #(
      .SCALING(ScoreCharScaling),
      .X_POS  (ScoreXStart + 2 * ScoreStep),
      .Y_POS  (HudYPos)
  ) score_o (
      .hpos(pix_x),
      .vpos(pix_y),
      .char("O"),
      .graphics(label_on_matrix[2])
  );

  character #(
      .SCALING(ScoreCharScaling),
      .X_POS  (ScoreXStart + 3 * ScoreStep),
      .Y_POS  (HudYPos)
  ) score_r (
      .hpos(pix_x),
      .vpos(pix_y),
      .char("R"),
      .graphics(label_on_matrix[3])
  );

  character #(
      .SCALING(ScoreCharScaling),
      .X_POS  (ScoreXStart + 4 * ScoreStep),
      .Y_POS  (HudYPos)
  ) score_e (
      .hpos(pix_x),
      .vpos(pix_y),
      .char("E"),
      .graphics(label_on_matrix[4])
  );

  always_comb begin
    label_on = |label_on_matrix;
  end

  // ---------

  // lives

  localparam int TotalLives = 3;
  logic [TotalLives-1:0] lives_matrix_raw;
  logic [TotalLives-1:0] lives_matrix;

  localparam logic [15:0] LiveW = 16;
  localparam logic [15:0] LiveGap = 4;
  localparam logic [15:0] LiveStep = (LiveW + LiveGap) * SCALE;

  genvar life;
  generate
    for (life = 0; life < TotalLives; life++) begin : gen_lives
      cannon #(
          .SHIP_Y(HudYPos),
          .SHIP_X(LivesXStart + life * LiveStep)
      ) life_cannon (
          .rst_n(0),
          .v_sync(0),
          .pix_x(pix_x),
          .pix_y(pix_y),
          .move_left(0),
          .move_right(0),
          .cannon_graphics(lives_matrix_raw[life]),
          .scale(SCALE)
      );
    end
  endgenerate

  // ---------

  // score value
  logic [3:0] score_d3, score_d2, score_d1, score_d0;  // thousands, hundreds, tens, ones

  logic [4:0] score_on_matrix;

  localparam logic [15:0] ScoreToDigitsGap = 2 * SCALE;

  character #(
    .SCALING(ScoreCharScaling),
    .X_POS  (ScoreXStart + 5 * ScoreStep + ScoreToDigitsGap),
    .Y_POS  (HudYPos)
  ) score_c3 (
    .hpos(pix_x),
    .vpos(pix_y),
    .char(score_d3),
    .graphics(score_on_matrix[3])
  );

  character #(
    .SCALING(ScoreCharScaling),
    .X_POS  (ScoreXStart + 6 * ScoreStep + ScoreToDigitsGap),
    .Y_POS  (HudYPos)
  ) score_c2 (
    .hpos(pix_x),
    .vpos(pix_y),
    .char(score_d2),
    .graphics(score_on_matrix[2])
  );

  character #(
    .SCALING(ScoreCharScaling),
    .X_POS  (ScoreXStart + 7 * ScoreStep + ScoreToDigitsGap),
    .Y_POS  (HudYPos)
  ) score_c1 (
    .hpos(pix_x),
    .vpos(pix_y),
    .char(score_d1),
    .graphics(score_on_matrix[1])
  );

  character #(
    .SCALING(ScoreCharScaling),
    .X_POS  (ScoreXStart + 8 * ScoreStep + ScoreToDigitsGap),
    .Y_POS  (HudYPos)
  ) score_c0 (
    .hpos(pix_x),
    .vpos(pix_y),
    .char(score_d0),
    .graphics(score_on_matrix[0])
  );


  always_comb begin
    score_d3 = 4'(32'(score) / 1000);
    score_d2 = 4'((32'(score) % 1000) / 100);
    score_d1 = 4'((32'(score) % 100) / 10);
    score_d0 = 4'(32'(score) % 10);
  end

  // ---------

  always_comb begin
    for (int i = 0; i < TotalLives; i++) lives_matrix[i] = lives_matrix_raw[i] & (lives > i);

    value_on = (|lives_matrix) | (|score_on_matrix);
  end

endmodule
