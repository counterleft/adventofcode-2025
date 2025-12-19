#!/usr/bin/env elixir

defmodule Day03 do
  @doc """
  Finds the maximum joltage by selecting exactly k batteries from a bank.
  Uses a greedy algorithm: for each position in the result, select the maximum
  digit from a window that ensures enough digits remain for future positions.

  This algorithm works for any k, including k=2 (part 1).

  Examples:
  - "818181911112111" with k=2 -> 92
  - "234234234234278" with k=12 -> 434234234278
    - Position 0: search window [0..3], max is 4 at index 2
    - Position 1: search window [3..4], max is 3 at index 4
    - And so on...
  """
  def max_joltage_k(bank, k) do
    digits = String.graphemes(bank)
    n = length(digits)

    # Greedy selection: for each result position, pick the max digit
    # from a window that leaves enough digits for remaining positions
    {result, _} = Enum.reduce(0..(k - 1), {[], 0}, fn i, {acc, current_pos} ->
      # Search window: current_pos to (n - k + i)
      # This ensures we have (k - i - 1) digits left after this selection
      end_pos = n - k + i

      # Find maximum digit in the window
      window = Enum.slice(digits, current_pos..end_pos)
      max_digit = Enum.max(window)

      # Find first occurrence of max_digit in window
      offset = Enum.find_index(window, fn d -> d == max_digit end)
      selected_pos = current_pos + offset

      # Add digit to result and update position to one past selected
      {acc ++ [Enum.at(digits, selected_pos)], selected_pos + 1}
    end)

    # Convert result to integer
    result |> Enum.join() |> String.to_integer()
  end

  @doc """
  Parses input into a list of battery banks (one per line).
  """
  def parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n", trim: true)
  end

  @doc """
  Solves part 1: finds the sum of maximum joltages from all banks (selecting 2 batteries).
  """
  def part1(banks) do
    banks
    |> Enum.map(&max_joltage_k(&1, 2))
    |> Enum.sum()
  end

  @doc """
  Solves part 2: finds the sum of maximum joltages when selecting 12 batteries per bank.
  """
  def part2(banks) do
    banks
    |> Enum.map(&max_joltage_k(&1, 12))
    |> Enum.sum()
  end

  def main do
    input = case System.argv() do
      [filename] -> File.read!(filename)
      [] ->
        case IO.read(:stdio, :eof) do
          :eof ->
            IO.puts("Usage: ./day03.exs <input_file>")
            System.halt(1)
          data -> data
        end
    end

    banks = parse_input(input)
    IO.puts("Part 1: #{part1(banks)}")
    IO.puts("Part 2: #{part2(banks)}")
  end
end

unless System.get_env("ELIXIR_TEST_MODE") == "true" do
  Day03.main()
end
