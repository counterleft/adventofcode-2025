#!/usr/bin/env elixir

defmodule Day02 do
  @doc """
  Returns all divisors of n that are less than n (for finding pattern lengths).
  For example: divisors(12) = [1, 2, 3, 4, 6]
  """
  def divisors(n) when n <= 1, do: []
  def divisors(n) do
    1..div(n, 2)
    |> Enum.filter(fn d -> rem(n, d) == 0 end)
  end

  @doc """
  Checks if a number is an invalid ID (pattern repeated exactly twice).
  For example: 11 (1 repeated), 6464 (64 repeated), 123123 (123 repeated)
  """
  def invalid_id?(n) do
    s = Integer.to_string(n)
    len = String.length(s)

    # Must have even number of digits
    if rem(len, 2) != 0 do
      false
    else
      mid = div(len, 2)
      first_half = String.slice(s, 0, mid)
      second_half = String.slice(s, mid, mid)
      first_half == second_half
    end
  end

  @doc """
  Checks if a number is an invalid ID (pattern repeated at least twice).
  Uses divisor optimization: only checks pattern lengths that divide the total length.
  For example: 123123 (123 repeated 2x), 1111111 (1 repeated 7x), 1212121212 (12 repeated 5x)
  """
  def invalid_id_part2?(n) do
    s = Integer.to_string(n)
    len = String.length(s)

    # Only check pattern lengths that are divisors of the total length
    divisors(len)
    |> Enum.any?(fn pattern_len ->
      pattern = String.slice(s, 0, pattern_len)
      repetitions = div(len, pattern_len)

      # Check if repeating the pattern recreates the original string
      String.duplicate(pattern, repetitions) == s
    end)
  end

  @doc """
  Parses a range string like "11-22" into {11, 22}
  """
  def parse_range(range_str) do
    [start, finish] = String.split(range_str, "-")
    {String.to_integer(start), String.to_integer(finish)}
  end

  @doc """
  Finds all invalid IDs (part 1) in a given range and returns their sum.
  """
  def sum_invalid_ids_in_range({start, finish}) do
    start..finish
    |> Enum.filter(&invalid_id?/1)
    |> Enum.sum()
  end

  @doc """
  Finds all invalid IDs (part 2) in a given range and returns their sum.
  """
  def sum_invalid_ids_in_range_part2({start, finish}) do
    start..finish
    |> Enum.filter(&invalid_id_part2?/1)
    |> Enum.sum()
  end

  @doc """
  Parses input and returns list of ranges.
  """
  def parse_input(input) do
    input
    |> String.trim()
    |> String.replace("\n", "")  # Remove line breaks
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&parse_range/1)
  end

  @doc """
  Solves part 1: sums all invalid IDs (pattern repeated exactly twice).
  """
  def part1(ranges) do
    ranges
    |> Enum.map(&sum_invalid_ids_in_range/1)
    |> Enum.sum()
  end

  @doc """
  Solves part 2: sums all invalid IDs (pattern repeated at least twice).
  """
  def part2(ranges) do
    ranges
    |> Enum.map(&sum_invalid_ids_in_range_part2/1)
    |> Enum.sum()
  end

  def main do
    input = case System.argv() do
      [filename] -> File.read!(filename)
      [] ->
        case IO.read(:stdio, :eof) do
          :eof ->
            IO.puts("Usage: ./day02.exs <input_file>")
            System.halt(1)
          data -> data
        end
    end

    ranges = parse_input(input)
    IO.puts("Part 1: #{part1(ranges)}")
    IO.puts("Part 2: #{part2(ranges)}")
  end
end

unless System.get_env("ELIXIR_TEST_MODE") == "true" do
  Day02.main()
end
