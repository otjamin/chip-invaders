"""
Modern cocotb 2.0 testbench for the Controller module.
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


class AlienTester:
    """Helper class for alien testing."""

    def __init__(self, dut):
        self.dut = dut
        self.clk = dut.clk
        self.rst_n = dut.rst_n
        self.alive = dut.alive
        self.enable = dut.enable
        self.hit_registered = dut.hit_registered
        self.movement_frequency = dut.movement_frequency
        self.movement_direction_x = dut.movement_direction_x
        self.movement_direction_y = dut.movement_direction_y
        self.movement_width = dut.movement_width
        self.armed = dut.armed
        self.frozen = dut.frozen
        self.scan_x = dut.scan_x
        self.scan_y = dut.scan_y
        self.graphics = dut.graphics

        self.basic_alien = []

        _hex_path = (
            Path(__file__).resolve().parent.parent / "src" / "rtl" / "basic_alien.hex"
        )
        with open(_hex_path, "r") as f:
            self.basic_alien = [
                [1 - int(bit) for bit in line.strip().replace(" ", "")]
                for line in f.readlines()
                if line.strip()
            ]

    async def reset_module(self):
        self.rst_n.value = 0
        self.enable.value = 1
        self.hit_registered.value = 0
        self.movement_direction_x.value = 0
        self.movement_direction_y.value = 0
        self.frozen.value = 0
        await FallingEdge(self.clk)
        self.rst_n.value = 1
        await RisingEdge(self.clk)

    async def set_pos(self, hpos: int = 0, vpos: int = 0):
        self.scan_x.value = hpos
        self.scan_y.value = vpos
        await FallingEdge(self.clk)


@cocotb.test()
async def test_reset(dut):
    """Test: Test reset"""
    tester = AlienTester(dut)

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    await tester.reset_module()
    tester.alive.value = 1

    hpos = 0
    vpos = 0
    await tester.set_pos(0, 0)

    have = int(str(tester.graphics.value), 2)

    # values after reset signal
    assert have == tester.basic_alien[hpos][vpos], (
        f"test_reset (x): Expected {tester.basic_alien[hpos][vpos]}, got {have}"
    )

    dut._log.info("✓ Reset test passed")


@cocotb.test()
async def test_sprite_graphics(dut):
    """Test: Test sprite graphics output"""
    tester = AlienTester(dut)

    scan_x = int(str(dut.INITIAL_POSITION_X.value), 2)
    scan_y = int(str(dut.INITIAL_POSITION_Y.value), 2)

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    tester.alive.value = 1
    tester.movement_frequency.value = 0
    tester.movement_width.value = 0
    tester.movement_direction_x.value = 1
    await RisingEdge(tester.clk)

    for y in range(len(tester.basic_alien)):
        for x in range(len(tester.basic_alien[0])):
            await tester.set_pos(scan_x + x, scan_y + y)

            have = int(str(tester.graphics.value), 2)
            expected = tester.basic_alien[y][x]

            assert have == expected, (
                f"test_move_right: Expected {expected}, got {have} "
                f"at scan=({scan_x + x},{scan_y + y}) sprite=({x},{y})"
            )

    dut._log.info("✓ Sprite graphics test passed")


@cocotb.test()
async def test_move_right(dut):
    """Test: Test moving right"""
    tester = AlienTester(dut)

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    for i in range(1, 20):
        frequency_value = 10
        movement_value = 10
        scan_x = int(str(dut.INITIAL_POSITION_X.value), 2)
        scan_y = int(str(dut.INITIAL_POSITION_Y.value), 2)

        await tester.reset_module()

        tester.alive.value = 1
        tester.movement_frequency.value = frequency_value
        tester.movement_width.value = movement_value
        tester.movement_direction_x.value = 1
        await RisingEdge(tester.clk)

        for _ in range(i * (frequency_value + 1)):
            await RisingEdge(tester.clk)

        tester.movement_frequency.value = 0
        tester.movement_width.value = 0

        sprite_height = len(tester.basic_alien)
        sprite_width = len(tester.basic_alien[0])

        for y in range(sprite_height):
            for x in range(sprite_width):
                await tester.set_pos(scan_x + x + i * movement_value, scan_y + y)

                have = int(str(tester.graphics.value), 2)
                expected = tester.basic_alien[y][x]

                assert have == expected, (
                    f"test_move_right: Expected {expected}, got {have} "
                    f"at scan=({scan_x + x + i * movement_value},{scan_y + y}) sprite=({x},{y})"
                )

    dut._log.info("✓ Test move right passed")


def test_alien_runner():
    sim = os.getenv("SIM", "icarus")

    proj_path = Path(__file__).resolve().parent.parent

    sim_build = proj_path / "test" / "sim_build"
    hex_dir = sim_build / "src" / "rtl"
    hex_dir.mkdir(parents=True, exist_ok=True)

    import shutil

    shutil.copy(
        proj_path / "src" / "rtl" / "basic_alien.hex", hex_dir / "basic_alien.hex"
    )

    sources = [proj_path / "src" / "rtl" / "alien.sv"]

    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="alien",
        always=True,
        waves=True,
        timescale=("1ns", "1ps"),
        build_dir=sim_build,
        parameters={
            "INITIAL_POSITION_X": 0,
            "INITIAL_POSITION_Y": 0,
            "MAX_POSITION_X": 640,
            "SCALING_FACTOR": 1,
        },
    )

    runner.test(
        hdl_toplevel="alien",
        test_module="test_alien",
        waves=True,
        build_dir=sim_build,
    )


if __name__ == "__main__":
    test_alien_runner()
