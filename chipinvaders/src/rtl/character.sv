module character # (
    parameter logic[15:0] SCALING = 1,
    parameter logic[15:0] X_POS = 0,
    parameter logic[15:0] Y_POS = 0
)(
    input logic v_sync,
    input logic[15:0] char, // ascii
    input logic[15:0] hpos,
    input logic[15:0] vpos,

    output logic graphics
);

    localparam logic[15:0] SpriteWidth = 5;
    localparam logic[15:0] SpriteHeight = 5;
    localparam logic[15:0] NumDigits = 10;

    logic [SpriteWidth-1:0] digits [0:NumDigits-1][0:SpriteHeight-1];

    initial begin
        $readmemb("src/rtl/digits.hex", digits);
    end

    logic is_digit;

    logic[15:0] digit_index;

    always_comb begin
        is_digit = (char >= "0") && (char <= "9");

        digit_index = char[15:0] - "0";

        if (is_digit)
            graphics = digits[digit_index][v_sync][SpriteWidth-1-hpos];
        else
            graphics = 0;
    end

endmodule
