module game_display (
    input  logic       rst_n,
    input  logic       clk,
    input  logic       enable,
    input  logic [9:0] pix_x,
    input  logic [9:0] pix_y,
    input  logic [1:0] state,
    input  logic       blink_signal,
    output logic [1:0] r,
    output logic [1:0] g,
    output logic [1:0] b
    //output logic       display_on
);

  // --- STATE PARAMETERS ---
  localparam logic [1:0] StateMENU = 2'd0;
  localparam logic [1:0] StateEND = 2'd2;

  // --- ANIMATION LOGIC (Typing & Scanline) ---
  logic [3:0] type_timer;
  logic [4:0] char_limit;
  logic [2:0] color_anim;

  always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      type_timer <= 4'd0;
      char_limit <= 5'd0;
      color_anim <= 3'd0;
    end else if (enable) begin
      color_anim <= color_anim + 1'b1;
      if (state == StateMENU) begin
        if (char_limit < 5'd17) begin
          if (type_timer == 4'd8) begin
            type_timer <= 4'd0;
            char_limit <= char_limit + 1'b1;
          end else type_timer <= type_timer + 1'b1;
        end
      end else begin
        char_limit <= 5'd0;
        type_timer <= 4'd0;
      end
    end
  end

  // --- HELPER FUNCTIONS ---
  function automatic logic draw_char(logic [23:0] code, logic [9:0] px, logic [9:0] py,
                                     logic [9:0] ox, logic [9:0] oy);
    if (px >= ox && px < ox + 32 && py >= oy && py < oy + 48)
      draw_char = code[23-(((py-oy)>>3)*4+((px-ox)>>3))];
    else draw_char = 1'b0;
  endfunction

  function automatic logic draw_sprite(logic [12:0] row_data, logic [9:0] px, logic [9:0] ox,
                                       logic [9:0] scale);
    // 13 bits max width for ship
    if (px >= ox && px < ox + (13 * scale)) draw_sprite = row_data[12-((px-ox)/scale)];
    else draw_sprite = 1'b0;
  endfunction

  // --- FONTS ---
  localparam logic [23:0] f_LT = 24'b0001_0010_0100_0100_0010_0001;  // <
  localparam logic [23:0] f_GT = 24'b1000_0100_0010_0010_0100_1000;  // >
  localparam logic [23:0] f_C = 24'b0110_1001_1000_1000_1001_0110;
  localparam logic [23:0] f_H = 24'b1001_1001_1111_1001_1001_1001;
  localparam logic [23:0] f_I = 24'b0110_0010_0010_0010_0010_0110;
  localparam logic [23:0] f_P = 24'b1110_1001_1110_1000_1000_1000;
  localparam logic [23:0] f_N = 24'b1001_1101_1011_1001_1001_1001;
  localparam logic [23:0] f_V = 24'b1001_1001_1001_1001_1001_0110;
  localparam logic [23:0] f_A = 24'b0110_1001_1111_1001_1001_1001;
  localparam logic [23:0] f_D = 24'b1110_1001_1001_1001_1001_1110;
  localparam logic [23:0] f_E = 24'b1111_1000_1110_1000_1000_1111;
  localparam logic [23:0] f_R = 24'b1110_1001_1110_1100_1010_1001;
  localparam logic [23:0] f_S = 24'b1111_1000_1110_0001_1001_1110;
  localparam logic [23:0] f_L = 24'b1000_1000_1000_1000_1000_1111;
  localparam logic [23:0] f_Y = 24'b1001_1001_0110_0010_0010_0010;
  localparam logic [23:0] f_G = 24'b0110_1001_1000_1011_1001_0110;
  localparam logic [23:0] f_O = 24'b0110_1001_1001_1001_1001_0110;
  localparam logic [23:0] f_M = 24'b1001_1111_1111_1001_1001_1001;
  localparam logic [23:0] f_T = 24'b1111_0100_0100_0100_0100_0100;

  // --- SPRITE DATA ---
  logic [12:0] ship_bmp[8];
  assign ship_bmp[0] = 13'b0000001000000;
  assign ship_bmp[1] = 13'b0000011100000;
  assign ship_bmp[2] = 13'b0000011100000;
  assign ship_bmp[3] = 13'b0111111111110;
  assign ship_bmp[4] = 13'b1111111111111;
  assign ship_bmp[5] = 13'b1111111111111;
  assign ship_bmp[6] = 13'b1111111111111;
  assign ship_bmp[7] = 13'b1111111111111;

  logic [10:0] alien_bmp[8];
  assign alien_bmp[0] = 11'b00011000110;
  assign alien_bmp[1] = 11'b01001111001;
  assign alien_bmp[2] = 11'b01111111111;
  assign alien_bmp[3] = 11'b11101110111;
  assign alien_bmp[4] = 11'b11111111111;
  assign alien_bmp[5] = 11'b00111111100;
  assign alien_bmp[6] = 11'b00100000100;
  assign alien_bmp[7] = 11'b01000000010;

  // --- ELEMENT SIGNALS ---
  logic
      title_on,
      play_on,
      game_over_on,
      restart_on,
      cover_ship_on,
      cover_aliens_on,
      cover_bullets_on,
      hit_effect_on;
  logic end_aliens_on;
  logic pix_y_bit2;

  // --- TITLE (MENU) ---
  localparam logic [9:0] TY = 10'd40;
  localparam logic [9:0] TX = 10'd16;
  localparam logic [9:0] SP_C = 10'd36;
  assign title_on = (char_limit > 5'd0 && draw_char(
      f_LT, pix_x, pix_y, TX, TY
  )) || (char_limit > 5'd2 && draw_char(
      f_C, pix_x, pix_y, TX + SP_C * 2, TY
  )) || (char_limit > 5'd3 && draw_char(
      f_H, pix_x, pix_y, TX + SP_C * 3, TY
  )) || (char_limit > 5'd4 && draw_char(
      f_I, pix_x, pix_y, TX + SP_C * 4, TY
  )) || (char_limit > 5'd5 && draw_char(
      f_P, pix_x, pix_y, TX + SP_C * 5, TY
  )) || (char_limit > 5'd7 && draw_char(
      f_I, pix_x, pix_y, TX + SP_C * 7, TY
  )) || (char_limit > 5'd8 && draw_char(
      f_N, pix_x, pix_y, TX + SP_C * 8, TY
  )) || (char_limit > 5'd9 && draw_char(
      f_V, pix_x, pix_y, TX + SP_C * 9, TY
  )) || (char_limit > 5'd10 && draw_char(
      f_A, pix_x, pix_y, TX + SP_C * 10, TY
  )) || (char_limit > 5'd11 && draw_char(
      f_D, pix_x, pix_y, TX + SP_C * 11, TY
  )) || (char_limit > 5'd12 && draw_char(
      f_E, pix_x, pix_y, TX + SP_C * 12, TY
  )) || (char_limit > 5'd13 && draw_char(
      f_R, pix_x, pix_y, TX + SP_C * 13, TY
  )) || (char_limit > 5'd14 && draw_char(
      f_S, pix_x, pix_y, TX + SP_C * 14, TY
  )) || (char_limit > 5'd16 && draw_char(
      f_GT, pix_x, pix_y, TX + SP_C * 16, TY
  ));

  // --- COVER ART ---
  localparam logic [9:0] SC = 10'd4;
  localparam logic [9:0] AY = 10'd120;
  localparam logic [9:0] AX2 = 10'd298;
  localparam logic [9:0] SY = 10'd240;
  localparam logic [9:0] SX = 10'd294;

  assign cover_aliens_on = (pix_x >= 10'd200 && pix_x < 10'd244 && pix_y >= AY && pix_y < AY+10'd32 && alien_bmp[(pix_y-AY)/SC][10-((pix_x-10'd200)/SC)]) ||
                             (pix_x >= AX2 && pix_x < AX2+10'd44 && pix_y >= AY && pix_y < AY+10'd32 && alien_bmp[(pix_y-AY)/SC][10-((pix_x-AX2)/SC)]) ||
                             (pix_x >= 10'd396 && pix_x < 10'd440 && pix_y >= AY && pix_y < AY+10'd32 && alien_bmp[(pix_y-AY)/SC][10-((pix_x-10'd396)/SC)]);

  assign cover_ship_on = (pix_y >= SY && pix_y < SY + 10'd32) && (draw_sprite(
      ship_bmp[3'((pix_y-SY)/SC)], pix_x, SX, SC
  ) == 1'b1);

  assign cover_bullets_on = ((pix_x >= 10'd316 && pix_x < 10'd324) && ((pix_y >= 10'd136 && pix_y < 10'd160) || (pix_y >= 10'd210 && pix_y < 10'd234)));

  assign hit_effect_on = (pix_x >= AX2-10'd10 && pix_x < AX2+10'd55 && pix_y >= AY && pix_y < AY+10'd40) && 
                           ((pix_x[3] ^ pix_y[3]) && (pix_x[1] == pix_y[1]));

  // --- MENU: PLAY ---
  localparam logic [9:0] MY = 10'd340;
  localparam logic [9:0] MX = 10'd240;
  assign play_on = blink_signal && (draw_char(
      f_P, pix_x, pix_y, MX, MY
  ) || draw_char(
      f_L, pix_x, pix_y, MX + 10'd40, MY
  ) || draw_char(
      f_A, pix_x, pix_y, MX + 10'd80, MY
  ) || draw_char(
      f_Y, pix_x, pix_y, MX + 10'd120, MY
  ));

  // --- GAME OVER SCREEN ---
  localparam logic [9:0] GOY = 10'd150;
  localparam logic [9:0] GOX = 10'd150;
  assign game_over_on = draw_char(
      f_G, pix_x, pix_y, GOX, GOY
  ) || draw_char(
      f_A, pix_x, pix_y, GOX + 10'd40, GOY
  ) || draw_char(
      f_M, pix_x, pix_y, GOX + 10'd80, GOY
  ) || draw_char(
      f_E, pix_x, pix_y, GOX + 10'd120, GOY
  ) || draw_char(
      f_O, pix_x, pix_y, GOX + 10'd200, GOY
  ) || draw_char(
      f_V, pix_x, pix_y, GOX + 10'd240, GOY
  ) || draw_char(
      f_E, pix_x, pix_y, GOX + 10'd280, GOY
  ) || draw_char(
      f_R, pix_x, pix_y, GOX + 10'd320, GOY
  );

  localparam logic [9:0] EAY = 10'd80;
  assign end_aliens_on = (pix_x >= 10'd240 && pix_x < 10'd284 && pix_y >= EAY && pix_y < EAY+10'd32 && alien_bmp[(pix_y-EAY)/SC][10-((pix_x-10'd240)/SC)]) ||
                           (pix_x >= 10'd356 && pix_x < 10'd400 && pix_y >= EAY && pix_y < EAY+10'd32 && alien_bmp[(pix_y-EAY)/SC][10-((pix_x-10'd356)/SC)]);

  localparam logic [9:0] RY = 10'd250;
  localparam logic [9:0] RX = 10'd180;
  assign restart_on = blink_signal && (draw_char(
      f_R, pix_x, pix_y, RX, RY
  ) || draw_char(
      f_E, pix_x, pix_y, RX + 10'd40, RY
  ) || draw_char(
      f_S, pix_x, pix_y, RX + 10'd80, RY
  ) || draw_char(
      f_T, pix_x, pix_y, RX + 10'd120, RY
  ) || draw_char(
      f_A, pix_x, pix_y, RX + 10'd160, RY
  ) || draw_char(
      f_R, pix_x, pix_y, RX + 10'd200, RY
  ) || draw_char(
      f_T, pix_x, pix_y, RX + 10'd240, RY
  ));

  // --- BIT EXTRACTION ---
  assign pix_y_bit2 = pix_y[2];

  // --- COLOR MIXER ---
  always_comb begin
    r = 2'd0;
    g = 2'd0;
    b = 2'd0;  // Default assignment
    if (state == StateMENU) begin  // MENU
      if (title_on || play_on || cover_aliens_on) begin
        r = 2'b11;
        g = 2'b11;
        b = 2'b11;
      end else if (cover_ship_on) begin
        r = 2'b00;
        g = 2'b11;
        b = 2'b00;
      end else if (cover_bullets_on || hit_effect_on) begin
        r = 2'b11;
        g = 2'b00;
        b = 2'b00;
      end
    end else if (state == StateEND) begin  // END
      if (game_over_on) begin
        r = (pix_y_bit2) ? 2'b11 : 2'b10;
        g = 2'b00;
        b = 2'b00;
      end else if (restart_on || end_aliens_on) begin
        r = 2'b11;
        g = 2'b11;
        b = 2'b11;
      end
    end
  end

  // assign display_on = (state == StateMENU && (title_on || play_on || cover_ship_on || cover_aliens_on || cover_bullets_on || hit_effect_on)) ||
  //                     (state == StateEND && (game_over_on || restart_on || end_aliens_on));

endmodule
