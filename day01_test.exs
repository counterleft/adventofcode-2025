#!/usr/bin/env elixir

# Set test mode flag before loading the main file
System.put_env("ELIXIR_TEST_MODE", "true")

Code.require_file("day01.exs", __DIR__)

ExUnit.start()

defmodule Day01Test do
  use ExUnit.Case

  test "dial wraps around correctly" do
    # Left from 50 by 50 reaches 0
    assert Day01.rotate(50, :left, 50) == 0

    # Left from 0 by 1 wraps to 99
    assert Day01.rotate(0, :left, 1) == 99

    # Right from 99 by 1 wraps to 0
    assert Day01.rotate(99, :right, 1) == 0
  end

  test "parse rotation instructions" do
    assert Day01.parse_rotation("L68") == {:left, 68}
    assert Day01.parse_rotation("R48") == {:right, 48}
    assert Day01.parse_rotation("L30") == {:left, 30}
  end

  test "rotation sequence positions" do
    # Starting at 50
    pos = 50

    # L68 -> 82
    pos = Day01.rotate(pos, :left, 68)
    assert pos == 82

    # L30 -> 52
    pos = Day01.rotate(pos, :left, 30)
    assert pos == 52

    # R48 -> 0
    pos = Day01.rotate(pos, :right, 48)
    assert pos == 0
  end

  test "count zero landings with simple sequence" do
    # Start at 50, rotate left 50 to land on 0
    rotations = ["L50"]
    assert Day01.part1(rotations) == 1

    # Multiple rotations that land on 0
    rotations = ["L50", "R100", "L0"]
    assert Day01.part1(rotations) == 3
  end

  test "sample file part 1 should return 3" do
    input = File.read!("day01_sample.txt")
    {result, _} = Day01.solve(input)
    assert result == 3
  end

  test "count zero clicks during rotations (part 2)" do
    # L68 from 50: crosses 0 once
    assert Day01.count_zero_crossings(50, :left, 68) == 1

    # L30 from 82: doesn't cross 0
    assert Day01.count_zero_crossings(82, :left, 30) == 0

    # R48 from 52: lands on 0 (crosses once)
    assert Day01.count_zero_crossings(52, :right, 48) == 1

    # R1000 from 50: crosses 0 ten times
    assert Day01.count_zero_crossings(50, :right, 1000) == 10
  end

  test "part 2 example sequence should return 6" do
    # From the problem: L68, L30, R48, L5, R60, L55, L1, L99, R14, L82
    # Should point at 0 six times total (3 at end + 3 during)
    rotations = ["L68", "L30", "R48", "L5", "R60", "L55", "L1", "L99", "R14", "L82"]
    assert Day01.part2(rotations) == 6
  end
end
