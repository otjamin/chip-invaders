"""
Modern cocotb 2.0 testbench for the Cannon module.
Uses async/await syntax and modern pythonic patterns.
"""

import os
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge
from cocotb.types import LogicArray

from cocotb_tools.runner import get_runner
import random

os.environ["COCOTB_ANSI_OUTPUT"] = "1"


class CannonTester:
    """Helper class for cannon testing."""

    def __init__(self, dut):
        self.dut = dut
        self.rst_n = dut.rst_n
        self.clk = dut.clk
        self.pix_x = dut.pix_x
        self.pix_y = dut.pix_y
        self.move_left = dut.move_left
        self.move_right = dut.move_right
        self.scale = dut.scale
        self.enable = dut.enable
        self.fire = dut.fire
        self.cannon_x_pos = dut.cannon_x_pos
        self.cannon_graphics = dut.cannon_graphics

        self.init_hpos = int((640 / 2) - (16 / 2))
        self.init_vpos = 440

        self.single_barrel_cannon = []

        _hex_path = (
            Path(__file__).resolve().parent.parent
            / "src"
            / "rtl"
            / "single_barrel_cannon.hex"
        )
        with open(_hex_path, "r") as f:
            self.single_barrel_cannon = [
                [1 - int(bit) for bit in line.strip().replace(" ", "")]
                for line in f.readlines()
                if line.strip()
            ]

    async def reset_module(self):
        self.rst_n.value = 0
        self.move_left.value = 0
        self.move_right.value = 0
        self.scale.value = 1
        self.enable.value = 1
        self.fire.value = 0
        self.pix_x.value = 0
        self.pix_y.value = 0
        await FallingEdge(self.clk)
        self.rst_n.value = 1
        await RisingEdge(self.clk)

    async def set_pos(self, hpos: int = 0, vpos: int = 0):
        self.pix_x.value = hpos
        self.pix_y.value = vpos
        await FallingEdge(self.clk)


@cocotb.test()
async def test_reset(dut):
    """Test: Test reset"""
    tester = CannonTester(dut)

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    await tester.reset_module()

    await tester.set_pos(tester.init_hpos, tester.init_vpos)

    have = int(str(tester.cannon_graphics.value), 2)

    # values after reset signal
    assert have == tester.single_barrel_cannon[0][0], (
        f"test_reset (x): Expected {tester.single_barrel_cannon[0][0]}, got {have}"
    )

    dut._log.info("✓ Reset test passed")


@cocotb.test()
async def test_sprite_graphics(dut):
    """Test: Test sprite graphics output"""
    tester = CannonTester(dut)

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    await RisingEdge(tester.clk)

    await tester.reset_module()

    for y in range(len(tester.single_barrel_cannon)):
        for x in range(len(tester.single_barrel_cannon[0])):
            await tester.set_pos(tester.init_hpos + x, tester.init_vpos + y)

            have = int(str(tester.cannon_graphics.value), 2)
            expected = tester.single_barrel_cannon[y][x]

            assert have == expected, (
                f"test_sprite_graphics: Expected {expected}, got {have} "
                f"at scan=({tester.init_hpos + x},{tester.init_vpos + y}) sprite=({x},{y})"
            )

    dut._log.info("✓ Sprite graphics test passed")


@cocotb.test()
async def test_move_right(dut):
    """Test: Test moving right"""
    tester = CannonTester(dut)

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    steps = 5
    speed = 4  # SPEED from cannon.sv

    await tester.reset_module()

    for _ in range(steps):
        tester.move_right.value = 1
        await RisingEdge(tester.clk)
    tester.move_right.value = 0

    expected_x = tester.init_hpos + steps * speed
    sprite_height = len(tester.single_barrel_cannon)
    sprite_width = len(tester.single_barrel_cannon[0])

    for y in range(sprite_height):
        for x in range(sprite_width):
            await tester.set_pos(expected_x + x, tester.init_vpos + y)

            have = int(str(tester.cannon_graphics.value), 2)
            expected = tester.single_barrel_cannon[y][x]

            assert have == expected, (
                f"test_move_right: Expected {expected}, got {have} "
                f"at scan=({expected_x + x},{tester.init_vpos + y}) sprite=({x},{y})"
            )

    dut._log.info("✓ Test move right passed")


@cocotb.test()
async def test_move_left(dut):
    """Test: Test moving left"""
    tester = CannonTester(dut)

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    steps = 5
    speed = 4  # SPEED from cannon.sv

    await tester.reset_module()

    for _ in range(steps):
        tester.move_left.value = 1
        await RisingEdge(tester.clk)
    tester.move_left.value = 0

    expected_x = tester.init_hpos - steps * speed
    sprite_height = len(tester.single_barrel_cannon)
    sprite_width = len(tester.single_barrel_cannon[0])

    for y in range(sprite_height):
        for x in range(sprite_width):
            await tester.set_pos(expected_x + x, tester.init_vpos + y)

            have = int(str(tester.cannon_graphics.value), 2)
            expected = tester.single_barrel_cannon[y][x]

            assert have == expected, (
                f"test_move_left: Expected {expected}, got {have} "
                f"at scan=({expected_x + x},{tester.init_vpos + y}) sprite=({x},{y})"
            )

    dut._log.info("✓ Test move left passed")


def test_cannon_runner():
    sim = os.getenv("SIM", "icarus")

    proj_path = Path(__file__).resolve().parent.parent

    sim_build = proj_path / "test" / "sim_build"
    hex_dir = sim_build / "src" / "rtl"
    hex_dir.mkdir(parents=True, exist_ok=True)

    import shutil

    shutil.copy(
        proj_path / "src" / "rtl" / "single_barrel_cannon.hex",
        hex_dir / "single_barrel_cannon.hex",
    )

    sources = [
        proj_path / "src" / "rtl" / "cannon.sv",
        proj_path / "src" / "rtl" / "cannon_display.sv",
    ]

    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="cannon",
        always=True,
        waves=True,
        timescale=("1ns", "1ps"),
        build_dir=sim_build,
    )

    runner.test(
        hdl_toplevel="cannon",
        test_module="test_cannon",
        waves=True,
        build_dir=sim_build,
    )


if __name__ == "__main__":
    test_cannon_runner()
