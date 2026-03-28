module top (
`ifdef USE_POWER_PINS
    inout wire IOVDD,
    inout wire IOVSS,
    inout wire VDD,
    inout wire VSS,
`endif

    inout clk_PAD,
    inout rst_n_PAD,
    inout button_left_PAD,
    inout button_right_PAD,
    inout button_shoot_PAD,

    output [3:0] vga_r_PADs,
    output [3:0] vga_g_PADs,
    output [3:0] vga_b_PADs,
    output vga_hs_PAD,
    output vga_vs_PAD
);

  logic clk;
  logic rst_n;
  logic btn_l;
  logic btn_r;
  logic btn_s;
  logic [3:0] vga_r;
  logic [3:0] vga_g;
  logic [3:0] vga_b;
  logic vga_hs;
  logic vga_vs;

  // Power/ground pad instances
  generate
    for (genvar i = 0; i < 1; i++) begin : iovdd_pads
      (* keep *)
      sg13cmos5l_IOPadIOVdd iovdd_pad (
`ifdef USE_POWER_PINS
          .iovdd(IOVDD),
          .iovss(IOVSS),
          .vdd  (VDD),
          .vss  (VSS)
`endif
      );
    end
    for (genvar i = 0; i < 1; i++) begin : iovss_pads
      (* keep *)
      sg13cmos5l_IOPadIOVss iovss_pad (
`ifdef USE_POWER_PINS
          .iovdd(IOVDD),
          .iovss(IOVSS),
          .vdd  (VDD),
          .vss  (VSS)
`endif
      );
    end
    for (genvar i = 0; i < 1; i++) begin : vdd_pads
      (* keep *)
      sg13cmos5l_IOPadVdd vdd_pad (
`ifdef USE_POWER_PINS
          .iovdd(IOVDD),
          .iovss(IOVSS),
          .vdd  (VDD),
          .vss  (VSS)
`endif
      );
    end
    for (genvar i = 0; i < 1; i++) begin : vss_pads
      (* keep *)
      sg13cmos5l_IOPadVss vss_pad (
`ifdef USE_POWER_PINS
          .iovdd(IOVDD),
          .iovss(IOVSS),
          .vdd  (VDD),
          .vss  (VSS)
`endif
      );
    end
  endgenerate
  // clk PAD instance
  sg13cmos5l_IOPadIn clk_pad (
`ifdef USE_POWER_PINS
      .iovdd(IOVDD),
      .iovss(IOVSS),
      .vdd  (VDD),
      .vss  (VSS),
`endif
      .p2c  (clk),
      .pad  (clk_PAD)
  );
  //reset PAD instance
  sg13cmos5l_IOPadIn rst_n_pad (
`ifdef USE_POWER_PINS
      .iovdd(IOVDD),
      .iovss(IOVSS),
      .vdd  (VDD),
      .vss  (VSS),
`endif
      .p2c  (rst_n),
      .pad  (rst_n_PAD)
  );
  //Button left PAD instance
  sg13cmos5l_IOPadIn button_left_pad (
`ifdef USE_POWER_PINS
      .iovdd(IOVDD),
      .iovss(IOVSS),
      .vdd  (VDD),
      .vss  (VSS),
`endif
      .p2c  (btn_l),
      .pad  (button_left_PAD)
  );
  //Button right PAD instance
  sg13cmos5l_IOPadIn button_right_pad (
`ifdef USE_POWER_PINS
      .iovdd(IOVDD),
      .iovss(IOVSS),
      .vdd  (VDD),
      .vss  (VSS),
`endif
      .p2c  (btn_r),
      .pad  (button_right_PAD)
  );
  //Button shoot PAD instance
  sg13cmos5l_IOPadIn button_shoot_pad (
`ifdef USE_POWER_PINS
      .iovdd(IOVDD),
      .iovss(IOVSS),
      .vdd  (VDD),
      .vss  (VSS),
`endif
      .p2c  (btn_s),
      .pad  (button_shoot_PAD)
  );
  // VGA Outputs PADs
  generate
    for (genvar i = 0; i < 4; i++) begin : vga_r_pads
      sg13cmos5l_IOPadOut30mA vga_r_pad (
`ifdef USE_POWER_PINS
          .vss  (VSS),
          .vdd  (VDD),
          .iovss(IOVSS),
          .iovdd(IOVDD),
`endif
          .c2p  (vga_r[i]),
          .pad  (vga_r_PADs[i])
      );
    end
  endgenerate
  generate
    for (genvar i = 0; i < 4; i++) begin : vga_g_pads
      sg13cmos5l_IOPadOut30mA vga_g_pad (
`ifdef USE_POWER_PINS
          .vss  (VSS),
          .vdd  (VDD),
          .iovss(IOVSS),
          .iovdd(IOVDD),
`endif
          .c2p  (vga_g[i]),
          .pad  (vga_g_PADs[i])
      );
    end
  endgenerate
  generate
    for (genvar i = 0; i < 4; i++) begin : vga_b_pads
      sg13cmos5l_IOPadOut30mA vga_b_pad (
`ifdef USE_POWER_PINS
          .vss  (VSS),
          .vdd  (VDD),
          .iovss(IOVSS),
          .iovdd(IOVDD),
`endif
          .c2p  (vga_b[i]),
          .pad  (vga_b_PADs[i])
      );
    end
  endgenerate
  sg13cmos5l_IOPadOut30mA vga_hs_pad (
`ifdef USE_POWER_PINS
      .vss  (VSS),
      .vdd  (VDD),
      .iovss(IOVSS),
      .iovdd(IOVDD),
`endif
      .c2p  (vga_hs),
      .pad  (vga_hs_PAD)
  );
  sg13cmos5l_IOPadOut30mA vga_vs_pad (
`ifdef USE_POWER_PINS
      .vss  (VSS),
      .vdd  (VDD),
      .iovss(IOVSS),
      .iovdd(IOVDD),
`endif
      .c2p  (vga_vs),
      .pad  (vga_vs_PAD)
  );

  chipinvaders game (
      .clk(clk),
      .rst_n(rst_n),
      .btn_l(btn_l),
      .btn_r(btn_r),
      .btn_u(btn_s),
      .vga_r(vga_r),
      .vga_g(vga_g),
      .vga_b(vga_b),
      .vga_hs(vga_hs),
      .vga_vs(vga_vs)
  );
endmodule
