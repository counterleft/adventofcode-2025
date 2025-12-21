#!/usr/bin/env elixir

defmodule Day05 do
  @doc """
  Part 1: Counts how many available ingredient IDs are fresh.
  Uses optimized range merging to minimize checks.
  """
  def part1({ranges, ingredient_ids}) do
    # Merge overlapping ranges for optimal checking
    merged_ranges = merge_ranges(ranges)

    # Count how many ingredient IDs fall within any fresh range
    Enum.count(ingredient_ids, fn id ->
      in_any_range?(id, merged_ranges)
    end)
  end

  @doc """
  Part 2: Counts the total number of ingredient IDs considered fresh.
  Returns the sum of all IDs covered by the merged ranges.
  """
  def part2({ranges, _ingredient_ids}) do
    # Merge overlapping ranges
    merged_ranges = merge_ranges(ranges)

    # Sum the size of each merged range
    Enum.reduce(merged_ranges, 0, fn {start, end_pos}, acc ->
      acc + (end_pos - start + 1)
    end)
  end

  # Merges overlapping or adjacent ranges into a minimal set.
  # Ranges are sorted by start position, then merged sequentially.
  defp merge_ranges(ranges) do
    ranges
    |> Enum.sort_by(fn {start, _end} -> start end)
    |> Enum.reduce([], fn {start, end_pos}, acc ->
      case acc do
        # First range
        [] ->
          [{start, end_pos}]

        # Can merge with previous range (overlapping or adjacent)
        [{prev_start, prev_end} | rest] when start <= prev_end + 1 ->
          [{prev_start, max(prev_end, end_pos)} | rest]

        # Cannot merge, add as new range
        _ ->
          [{start, end_pos} | acc]
      end
    end)
    |> Enum.reverse()
  end

  # Checks if a value falls within any of the given ranges.
  # Uses early termination for efficiency.
  defp in_any_range?(value, ranges) do
    Enum.any?(ranges, fn {start, end_pos} ->
      value >= start and value <= end_pos
    end)
  end

  @doc """
  Parses the input into ranges and ingredient IDs.
  Format: ranges section, blank line, ingredient IDs section.
  """
  def parse_input(input) do
    [ranges_section, ids_section] =
      input
      |> String.trim()
      |> String.split("\n\n", parts: 2)

    # Parse ranges (e.g., "3-5" -> {3, 5})
    ranges =
      ranges_section
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [start, end_pos] = String.split(line, "-")
        {String.to_integer(start), String.to_integer(end_pos)}
      end)

    # Parse ingredient IDs
    ingredient_ids =
      ids_section
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_integer/1)

    {ranges, ingredient_ids}
  end

  def main do
    input = case System.argv() do
      [filename] -> File.read!(filename)
      [] ->
        case IO.read(:stdio, :eof) do
          :eof ->
            IO.puts("Usage: ./day05.exs <input_file>")
            System.halt(1)
          data -> data
        end
    end

    data = parse_input(input)
    IO.puts("Part 1: #{part1(data)}")
    IO.puts("Part 2: #{part2(data)}")
  end
end

unless System.get_env("ELIXIR_TEST_MODE") == "true" do
  Day05.main()
end
