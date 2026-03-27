module game_state_machine (
    input  logic       rst_n,
    input  logic       clk,
    input  logic       enable,
    input  logic       trigger_in,         // Direct trigger button
    input  logic       game_over_trigger,  // External game over signal
    output logic [1:0] state,              // 0: MENU, 1: GAME, 2: END
    output logic       blink_signal,       // Blink signal
    output logic       reset_game          // Reset signal for game components
);

  localparam logic [1:0] StateMENU = 2'd0;
  localparam logic [1:0] StateGAME = 2'd1;
  localparam logic [1:0] StateEND = 2'd2;

  logic [5:0] blink_timer;
  assign blink_signal = blink_timer[5];

  // Internal state for edge detection
  logic prev_trigger;

  always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      state <= StateMENU;
      blink_timer <= 6'd0;
      prev_trigger <= 1'b0;
      reset_game <= 1'b0;
    end else if (enable) begin
      blink_timer <= blink_timer + 1'b1;
      reset_game  <= 1'b0;  // Default: no reset

      // Detect rising edge of trigger_in
      if (trigger_in && !prev_trigger) begin
        case (state)
          StateMENU: begin
            state <= StateGAME;
            reset_game <= 1'b1;  // Reset game when starting
          end
          StateEND: begin
            state <= StateMENU;
            reset_game <= 1'b1;  // Reset when returning to menu
          end
          default: ;  // Do nothing in GAME state
        endcase
      end

      // Check for game over
      if (game_over_trigger) state <= StateEND;

      prev_trigger <= trigger_in;  // Save previous state
    end
  end

endmodule
