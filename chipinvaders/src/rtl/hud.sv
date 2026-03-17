`default_nettype none

/**
 * Module: hud
 * Description: UI Head-Up Display for the game (Score and Lives).
 * This module receives screen coordinates and game state to output RGB signals.
 * You can change the colors, and need to give it coordinates, the lives and score, its just a hud that shows information on the screen
 * It also has a scaling variable
 */
module hud (
    input  logic [ 9:0] pix_x,     // Current beam X position
    input  logic [ 9:0] pix_y,     // Current beam Y position
    input  logic [ 1:0] lives,     // Current player lives (0-3)
    input  logic [13:0] score,     // Current player score (0-9999)
    input  logic [ 3:0] scale,     // Scaling factor (e.g., 2, 4)
    output logic        label_on,  // High when a "SCORE:" label pixel is active
    output logic        value_on   // High when a score digit or lives icon pixel is active
);

  // --- DIMENSIONS AND POSITIONS ---
  localparam int CHAR_WIDTH = 5;
  localparam int CHAR_HEIGHT = 5;
  localparam int SHIP_WIDTH = 13;
  localparam int SHIP_HEIGHT = 8;

  localparam logic [9:0] HUD_Y_POS = 10'd20;
  localparam logic [9:0] SCORE_X_START = 10'd40;
  localparam logic [9:0] LIVES_X_START = 10'd500;


  // static "SCORE"

  localparam logic [15:0] ScoreCharScaling = 8;
  localparam logic [15:0] ScoreCharW = 5;
  localparam logic [15:0] ScoreCharGap = 1;
  localparam logic [15:0] ScoreStep = (ScoreCharW + ScoreCharGap) * ScoreCharScaling;

  logic [4:0] letter_on_matrix;

  character #(
      .SCALING(ScoreCharScaling),
      .X_POS  (SCORE_X_START + 0 * ScoreStep),
      .Y_POS  (HUD_Y_POS)
  ) score_s (
      .hpos(pix_x),
      .vpos(pix_y),
      .char("S"),
      .graphics(letter_on_matrix[0])
  );

  character #(
      .SCALING(ScoreCharScaling),
      .X_POS  (SCORE_X_START + 1 * ScoreStep),
      .Y_POS  (HUD_Y_POS)
  ) score_c (
      .hpos(pix_x),
      .vpos(pix_y),
      .char("C"),
      .graphics(letter_on_matrix[1])
  );

  character #(
      .SCALING(ScoreCharScaling),
      .X_POS  (SCORE_X_START + 2 * ScoreStep),
      .Y_POS  (HUD_Y_POS)
  ) score_o (
      .hpos(pix_x),
      .vpos(pix_y),
      .char("O"),
      .graphics(letter_on_matrix[2])
  );

  character #(
      .SCALING(ScoreCharScaling),
      .X_POS  (SCORE_X_START + 3 * ScoreStep),
      .Y_POS  (HUD_Y_POS)
  ) score_r (
      .hpos(pix_x),
      .vpos(pix_y),
      .char("R"),
      .graphics(letter_on_matrix[3])
  );

  character #(
      .SCALING(ScoreCharScaling),
      .X_POS  (SCORE_X_START + 4 * ScoreStep),
      .Y_POS  (HUD_Y_POS)
  ) score_e (
      .hpos(pix_x),
      .vpos(pix_y),
      .char("E"),
      .graphics(letter_on_matrix[4])
  );

  // ---------


  // --- DIGIT BITMAP FUNCTION (5 wide x 7 tall, bit 4 = leftmost column) ---
  function automatic logic [4:0] digit_row(input logic [3:0] d, input logic [2:0] row);
    case ({
      d, row
    })
      {4'd0, 3'd0} : digit_row = 5'b01110;
      {4'd0, 3'd1} : digit_row = 5'b10001;
      {4'd0, 3'd2} : digit_row = 5'b10001;
      {4'd0, 3'd3} : digit_row = 5'b10001;
      {4'd0, 3'd4} : digit_row = 5'b10001;
      {4'd0, 3'd5} : digit_row = 5'b10001;
      {4'd0, 3'd6} : digit_row = 5'b01110;
      {4'd1, 3'd0} : digit_row = 5'b00100;
      {4'd1, 3'd1} : digit_row = 5'b01100;
      {4'd1, 3'd2} : digit_row = 5'b00100;
      {4'd1, 3'd3} : digit_row = 5'b00100;
      {4'd1, 3'd4} : digit_row = 5'b00100;
      {4'd1, 3'd5} : digit_row = 5'b00100;
      {4'd1, 3'd6} : digit_row = 5'b01110;
      {4'd2, 3'd0} : digit_row = 5'b01110;
      {4'd2, 3'd1} : digit_row = 5'b10001;
      {4'd2, 3'd2} : digit_row = 5'b00001;
      {4'd2, 3'd3} : digit_row = 5'b00110;
      {4'd2, 3'd4} : digit_row = 5'b01000;
      {4'd2, 3'd5} : digit_row = 5'b10000;
      {4'd2, 3'd6} : digit_row = 5'b11111;
      {4'd3, 3'd0} : digit_row = 5'b01110;
      {4'd3, 3'd1} : digit_row = 5'b10001;
      {4'd3, 3'd2} : digit_row = 5'b00001;
      {4'd3, 3'd3} : digit_row = 5'b00110;
      {4'd3, 3'd4} : digit_row = 5'b00001;
      {4'd3, 3'd5} : digit_row = 5'b10001;
      {4'd3, 3'd6} : digit_row = 5'b01110;
      {4'd4, 3'd0} : digit_row = 5'b10001;
      {4'd4, 3'd1} : digit_row = 5'b10001;
      {4'd4, 3'd2} : digit_row = 5'b10001;
      {4'd4, 3'd3} : digit_row = 5'b11111;
      {4'd4, 3'd4} : digit_row = 5'b00001;
      {4'd4, 3'd5} : digit_row = 5'b00001;
      {4'd4, 3'd6} : digit_row = 5'b00001;
      {4'd5, 3'd0} : digit_row = 5'b11111;
      {4'd5, 3'd1} : digit_row = 5'b10000;
      {4'd5, 3'd2} : digit_row = 5'b10000;
      {4'd5, 3'd3} : digit_row = 5'b11110;
      {4'd5, 3'd4} : digit_row = 5'b00001;
      {4'd5, 3'd5} : digit_row = 5'b00001;
      {4'd5, 3'd6} : digit_row = 5'b11110;
      {4'd6, 3'd0} : digit_row = 5'b01110;
      {4'd6, 3'd1} : digit_row = 5'b10000;
      {4'd6, 3'd2} : digit_row = 5'b10000;
      {4'd6, 3'd3} : digit_row = 5'b11110;
      {4'd6, 3'd4} : digit_row = 5'b10001;
      {4'd6, 3'd5} : digit_row = 5'b10001;
      {4'd6, 3'd6} : digit_row = 5'b01110;
      {4'd7, 3'd0} : digit_row = 5'b11111;
      {4'd7, 3'd1} : digit_row = 5'b00001;
      {4'd7, 3'd2} : digit_row = 5'b00010;
      {4'd7, 3'd3} : digit_row = 5'b00100;
      {4'd7, 3'd4} : digit_row = 5'b01000;
      {4'd7, 3'd5} : digit_row = 5'b01000;
      {4'd7, 3'd6} : digit_row = 5'b01000;
      {4'd8, 3'd0} : digit_row = 5'b01110;
      {4'd8, 3'd1} : digit_row = 5'b10001;
      {4'd8, 3'd2} : digit_row = 5'b10001;
      {4'd8, 3'd3} : digit_row = 5'b01110;
      {4'd8, 3'd4} : digit_row = 5'b10001;
      {4'd8, 3'd5} : digit_row = 5'b10001;
      {4'd8, 3'd6} : digit_row = 5'b01110;
      {4'd9, 3'd0} : digit_row = 5'b01110;
      {4'd9, 3'd1} : digit_row = 5'b10001;
      {4'd9, 3'd2} : digit_row = 5'b10001;
      {4'd9, 3'd3} : digit_row = 5'b01111;
      {4'd9, 3'd4} : digit_row = 5'b00001;
      {4'd9, 3'd5} : digit_row = 5'b00001;
      {4'd9, 3'd6} : digit_row = 5'b01110;
      default:       digit_row = 5'b00000;
    endcase
  endfunction

  // --- INTERNAL SIGNALS ---
  logic letter_on;
  logic [9:0] scaled_char_w, scaled_char_h;
  logic [9:0] scaled_ship_w, scaled_ship_h;
  logic [9:0] rel_x, rel_y;
  logic [9:0] ship_rel_x, ship_rel_y;
  logic [3:0] score_d3, score_d2, score_d1, score_d0;  // thousands, hundreds, tens, ones
  logic [9:0] digit_x_base;  // x start of score digit area
  logic [3:0] disp_digit;  // digit value currently being rendered
  logic [9:0] slot_x;  // x offset within the current digit slot
  logic [4:0] digit_row_bits;  // scratch: one row of the current digit

  assign scaled_char_w = 10'(CHAR_WIDTH * scale);
  assign scaled_char_h = 10'(CHAR_HEIGHT * scale);
  assign scaled_ship_w = 10'(SHIP_WIDTH * scale);
  assign scaled_ship_h = 10'(SHIP_HEIGHT * scale);

  // --- SHIP BITMAP (For Lives) ---
  logic [12:0] ship_bitmap[8];
  always_comb begin
    ship_bitmap[0] = 13'b0000001000000;
    ship_bitmap[1] = 13'b0000011100000;
    ship_bitmap[2] = 13'b0000011100000;
    ship_bitmap[3] = 13'b0111111111110;
    ship_bitmap[4] = 13'b1111111111111;
    ship_bitmap[5] = 13'b1111111111111;
    ship_bitmap[6] = 13'b1111111111111;
    ship_bitmap[7] = 13'b1111111111111;
  end

  // --- RENDERING LOGIC ---
  always_comb begin
    letter_on = 1'b0;
    label_on = 1'b0;
    value_on = 1'b0;
    rel_x = 10'b0;
    rel_y = 10'b0;
    ship_rel_x = 10'b0;
    ship_rel_y = 10'b0;
    score_d3 = 4'(32'(score) / 1000);
    score_d2 = 4'((32'(score) % 1000) / 100);
    score_d1 = 4'((32'(score) % 100) / 10);
    score_d0 = 4'(32'(score) % 10);
    digit_x_base = SCORE_X_START + ((scaled_char_w * 17) >> 1);
    disp_digit = 4'hF;  // sentinel: no digit
    slot_x = 10'b0;
    digit_row_bits = 5'b00000;

    // --- SCORE SECTION (Characters) ---
    if (pix_y >= HUD_Y_POS && pix_y < HUD_Y_POS + scaled_char_h) begin
      letter_on = |letter_on_matrix;
      if (letter_on) label_on = 1'b1;  // "SCORE:" label

      // Render score value digits (green, no leading zeros)
      // Digit slots spaced 1.5×char_w apart:
      //   slot 0 → digit_x_base
      //   slot 1 → +1.5cw
      //   slot 2 → +3cw
      //   slot 3 → +4.5cw
      disp_digit = 4'hF;
      slot_x     = 10'b0;

      if (score >= 1000) begin
        // Four digits: thousands | hundreds | tens | ones
        if (pix_x >= digit_x_base && pix_x < digit_x_base + scaled_char_w) begin
          disp_digit = score_d3;
          slot_x     = pix_x - digit_x_base;
        end else if (pix_x >= digit_x_base + ((scaled_char_w * 3) >> 1) &&
                             pix_x <  digit_x_base + ((scaled_char_w * 5) >> 1)) begin
          disp_digit = score_d2;
          slot_x     = pix_x - (digit_x_base + ((scaled_char_w * 3) >> 1));
        end else if (pix_x >= digit_x_base + (scaled_char_w * 3) &&
                             pix_x <  digit_x_base + (scaled_char_w * 4)) begin
          disp_digit = score_d1;
          slot_x     = pix_x - (digit_x_base + (scaled_char_w * 3));
        end else if (pix_x >= digit_x_base + ((scaled_char_w * 9) >> 1) &&
                             pix_x <  digit_x_base + ((scaled_char_w * 11) >> 1)) begin
          disp_digit = score_d0;
          slot_x     = pix_x - (digit_x_base + ((scaled_char_w * 9) >> 1));
        end
      end else if (score >= 100) begin
        // Three digits: hundreds | tens | ones
        if (pix_x >= digit_x_base && pix_x < digit_x_base + scaled_char_w) begin
          disp_digit = score_d2;
          slot_x     = pix_x - digit_x_base;
        end else if (pix_x >= digit_x_base + ((scaled_char_w * 3) >> 1) &&
                             pix_x <  digit_x_base + ((scaled_char_w * 5) >> 1)) begin
          disp_digit = score_d1;
          slot_x     = pix_x - (digit_x_base + ((scaled_char_w * 3) >> 1));
        end else if (pix_x >= digit_x_base + (scaled_char_w * 3) &&
                             pix_x <  digit_x_base + (scaled_char_w * 4)) begin
          disp_digit = score_d0;
          slot_x     = pix_x - (digit_x_base + (scaled_char_w * 3));
        end
      end else if (score >= 10) begin
        // Two digits: tens | ones
        if (pix_x >= digit_x_base && pix_x < digit_x_base + scaled_char_w) begin
          disp_digit = score_d1;
          slot_x     = pix_x - digit_x_base;
        end else if (pix_x >= digit_x_base + ((scaled_char_w * 3) >> 1) &&
                             pix_x <  digit_x_base + ((scaled_char_w * 5) >> 1)) begin
          disp_digit = score_d0;
          slot_x     = pix_x - (digit_x_base + ((scaled_char_w * 3) >> 1));
        end
      end else begin
        // One digit: ones
        if (pix_x >= digit_x_base && pix_x < digit_x_base + scaled_char_w) begin
          disp_digit = score_d0;
          slot_x     = pix_x - digit_x_base;
        end
      end

      if (disp_digit != 4'hF) begin
        rel_x = slot_x / 10'(scale);
        digit_row_bits = digit_row(disp_digit, rel_y[2:0]);
        if (digit_row_bits[4-rel_x[2:0]]) value_on = 1'b1;  // score digit
      end
    end

    // --- LIVES SECTION (Mini Ships) ---
    if (pix_y >= HUD_Y_POS && pix_y < HUD_Y_POS + scaled_ship_h) begin
      ship_rel_y = (pix_y - HUD_Y_POS) / 10'(scale);

      // Display ship icons based on lives remaining
      if (lives >= 1 && pix_x >= LIVES_X_START && pix_x < LIVES_X_START + scaled_ship_w) begin
        ship_rel_x = (pix_x - LIVES_X_START) / 10'(scale);
        if (ship_bitmap[ship_rel_y[2:0]][12-ship_rel_x[3:0]]) value_on = 1'b1;  // life 1
      end
            else if (lives >= 2 && pix_x >= LIVES_X_START + ((scaled_ship_w * 3) >> 1) &&
                     pix_x < LIVES_X_START + ((scaled_ship_w * 5) >> 1)) begin
        ship_rel_x = (pix_x - (LIVES_X_START + ((scaled_ship_w * 3) >> 1))) / 10'(scale);
        if (ship_bitmap[ship_rel_y[2:0]][12-ship_rel_x[3:0]]) value_on = 1'b1;
      end
            else if (lives >= 3 && pix_x >= LIVES_X_START + (scaled_ship_w * 3) &&
                     pix_x < LIVES_X_START + (scaled_ship_w * 4)) begin
        ship_rel_x = (pix_x - (LIVES_X_START + (scaled_ship_w * 3))) / 10'(scale);
        if (ship_bitmap[ship_rel_y[2:0]][12-ship_rel_x[3:0]]) value_on = 1'b1;
      end
    end
  end

endmodule
