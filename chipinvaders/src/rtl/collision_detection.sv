
module collision_detection #(
    parameter logic [15:0] NUMBER_ROWS = 2,
    parameter logic [15:0] NUMBER_COLUMNS = 4
) (
    input logic clk,
    input logic rst_n,

    input logic [15:0] [NUMBER_ROWS-1:0][NUMBER_COLUMNS-1:0] alien_position_x_matrix,
    input logic [15:0] [NUMBER_ROWS-1:0][NUMBER_COLUMNS-1:0] alien_position_y_matrix,
    input logic laser_active,
    input logic [15:0] laser_x,
    input logic [15:0] laser_y,

    output logic [NUMBER_ROWS-1:0][NUMBER_COLUMNS-1:0] hit_matrix
);

logic [15:0] dummy;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dummy <= 0;
    end else begin
        dummy <= 1;
    end
end

endmodule
