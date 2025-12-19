#!/usr/bin/env elixir

defmodule Day01 do
  @dial_size 100
  @start_position 50

  @doc """
  Parses a rotation instruction like "L68" or "R48".
  """
  def parse_rotation("L" <> num), do: {:left, String.to_integer(num)}
  def parse_rotation("R" <> num), do: {:right, String.to_integer(num)}

  @doc """
  Counts how many times the dial points at 0 during a rotation.
  """
  def count_zero_crossings(pos, :left, amount) do
    cond do
      pos == 0 -> div(amount, @dial_size)
      amount >= pos -> 1 + div(amount - pos, @dial_size)
      true -> 0
    end
  end

  def count_zero_crossings(pos, :right, amount) do
    cond do
      pos == 0 -> div(amount, @dial_size)
      amount >= @dial_size - pos -> 1 + div(amount - (@dial_size - pos), @dial_size)
      true -> 0
    end
  end

  @doc """
  Applies rotation and returns new position.
  """
  def rotate(pos, :left, amount), do: Integer.mod(pos - amount, @dial_size)
  def rotate(pos, :right, amount), do: Integer.mod(pos + amount, @dial_size)

  @doc """
  Solves part 1: count times dial lands on 0 at end of rotations.
  """
  def part1(rotations) do
    Enum.reduce(rotations, {@start_position, 0}, fn rotation, {pos, count} ->
      {dir, amt} = parse_rotation(rotation)
      new_pos = rotate(pos, dir, amt)
      new_count = if new_pos == 0, do: count + 1, else: count
      {new_pos, new_count}
    end)
    |> elem(1)
  end

  @doc """
  Solves part 2: count all clicks that point at 0.
  """
  def part2(rotations) do
    Enum.reduce(rotations, {@start_position, 0}, fn rotation, {pos, count} ->
      {dir, amt} = parse_rotation(rotation)
      crossings = count_zero_crossings(pos, dir, amt)
      new_pos = rotate(pos, dir, amt)
      {new_pos, count + crossings}
    end)
    |> elem(1)
  end

  def solve(input) do
    rotations =
      input
      |> String.trim()
      |> String.split("\n", trim: true)
      |> Enum.map(&String.trim/1)

    {part1(rotations), part2(rotations)}
  end

  def main do
    input = case System.argv() do
      [filename] -> File.read!(filename)
      [] ->
        case IO.read(:stdio, :eof) do
          :eof ->
            IO.puts("Usage: ./day01_simple.exs <input_file>")
            System.halt(1)
          data -> data
        end
    end

    {result1, result2} = solve(input)
    IO.puts("Part 1: #{result1}")
    IO.puts("Part 2: #{result2}")
  end
end

unless System.get_env("ELIXIR_TEST_MODE") == "true" do
  Day01.main()
end
