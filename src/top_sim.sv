module top_sim (
    input logic clk,
    input logic rst_n,

    input logic key_up,
    input logic key_left,
    input logic key_right,

    output logic [1:0] r,
    g,
    b,
    output logic hsync,
    output logic vsync
);

  logic [3:0] vga_r;
  logic [3:0] vga_g;
  logic [3:0] vga_b;

  chipinvaders game (
      .clk(clk),
      .rst_n(rst_n),
      .btn_u(key_up),
      .btn_l(key_left),
      .btn_r(key_right),
      .vga_r(vga_r),
      .vga_g(vga_g),
      .vga_b(vga_b),
      .vga_hs(hsync),
      .vga_vs(vsync)
  );

  assign r = vga_r[3:2];
  assign g = vga_g[3:2];
  assign b = vga_b[3:2];

endmodule
