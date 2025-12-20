#!/usr/bin/env elixir

defmodule Day04 do
  @doc """
  Part 1: Counts rolls of paper that can be accessed by a forklift.
  A roll (@) is accessible if it has fewer than 4 adjacent rolls in the 8 neighboring positions.
  """
  def part1(grid) do
    count_accessible_rolls(grid)
  end

  @doc """
  Part 2: Simulates removing accessible rolls iteratively until no more can be removed.
  Returns the total number of rolls removed.
  """
  def part2(grid) do
    # Convert to a mutable grid representation (MapSet of {row, col} positions)
    rolls = grid_to_rolls(grid)
    remove_all_accessible(rolls, 0)
  end

  # Converts grid to a MapSet of {row, col} positions containing rolls
  defp grid_to_rolls(grid) do
    for {line, row} <- Enum.with_index(grid),
        {char, col} <- Enum.with_index(String.graphemes(line)),
        char == "@" do
      {row, col}
    end
    |> MapSet.new()
  end

  # Recursively removes accessible rolls until none remain
  defp remove_all_accessible(rolls, total_removed) do
    accessible = find_accessible_positions(rolls)

    if MapSet.size(accessible) == 0 do
      total_removed
    else
      new_rolls = MapSet.difference(rolls, accessible)
      remove_all_accessible(new_rolls, total_removed + MapSet.size(accessible))
    end
  end

  # Finds all positions with rolls that have < 4 adjacent rolls
  defp find_accessible_positions(rolls) do
    Enum.filter(rolls, fn pos ->
      count_adjacent_rolls_in_set(rolls, pos) < 4
    end)
    |> MapSet.new()
  end

  # Counts adjacent rolls for a position in a MapSet
  defp count_adjacent_rolls_in_set(rolls, {row, col}) do
    directions = [
      {-1, -1}, {-1, 0}, {-1, 1},
      {0, -1},           {0, 1},
      {1, -1},  {1, 0},  {1, 1}
    ]

    Enum.count(directions, fn {dr, dc} ->
      MapSet.member?(rolls, {row + dr, col + dc})
    end)
  end

  # Part 1 helper: counts accessible rolls in original grid format
  defp count_accessible_rolls(grid) do
    height = length(grid)
    width = if height > 0, do: String.length(hd(grid)), else: 0

    for row <- 0..(height - 1),
        col <- 0..(width - 1),
        get_cell(grid, row, col) == "@",
        count_adjacent_rolls(grid, row, col) < 4 do
      1
    end
    |> Enum.sum()
  end

  # Counts how many of the 8 adjacent positions contain rolls of paper.
  defp count_adjacent_rolls(grid, row, col) do
    # All 8 directions: up, down, left, right, and 4 diagonals
    directions = [
      {-1, -1}, {-1, 0}, {-1, 1},  # top-left, top, top-right
      {0, -1},           {0, 1},    # left, right
      {1, -1},  {1, 0},  {1, 1}     # bottom-left, bottom, bottom-right
    ]

    Enum.count(directions, fn {dr, dc} ->
      get_cell(grid, row + dr, col + dc) == "@"
    end)
  end

  # Gets the character at a specific position in the grid.
  # Returns "." if out of bounds.
  defp get_cell(grid, row, col) do
    if row >= 0 and row < length(grid) do
      line = Enum.at(grid, row)
      if col >= 0 and col < String.length(line) do
        String.at(line, col)
      else
        "."
      end
    else
      "."
    end
  end

  @doc """
  Parses input into a list of strings (one per row).
  """
  def parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n", trim: true)
  end

  def main do
    input = case System.argv() do
      [filename] -> File.read!(filename)
      [] ->
        case IO.read(:stdio, :eof) do
          :eof ->
            IO.puts("Usage: ./day04.exs <input_file>")
            System.halt(1)
          data -> data
        end
    end

    grid = parse_input(input)
    IO.puts("Part 1: #{part1(grid)}")
    IO.puts("Part 2: #{part2(grid)}")
  end
end

unless System.get_env("ELIXIR_TEST_MODE") == "true" do
  Day04.main()
end
