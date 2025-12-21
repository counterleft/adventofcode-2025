#!/usr/bin/env elixir

defmodule Day07 do
  def solve_part1(input) do
    grid = parse_grid(input)
    start_pos = find_start(grid)

    {_beams_seen, splitters_hit} = simulate([start_pos], MapSet.new(), MapSet.new(), grid)
    MapSet.size(splitters_hit)
  end

  def solve_part2(input) do
    grid = parse_grid(input)
    start_pos = find_start(grid)

    # Count timelines (paths from S to bottom)
    {count, _memo} = count_timelines(start_pos, grid, %{})
    count
  end

  defp parse_grid(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end

  defp find_start(grid) do
    grid
    |> Enum.with_index()
    |> Enum.find_value(fn {row, r} ->
      case Enum.find_index(row, &(&1 == "S")) do
        nil -> nil
        c -> {r, c}
      end
    end)
  end

  defp simulate([], seen, splitters_hit, _grid), do: {seen, splitters_hit}

  defp simulate([pos | rest], seen, splitters_hit, grid) do
    if MapSet.member?(seen, pos) do
      # Already processed this beam starting position
      simulate(rest, seen, splitters_hit, grid)
    else
      seen = MapSet.put(seen, pos)
      {new_beams, hit_splitter} = trace_beam(pos, grid)

      splitters_hit =
        case hit_splitter do
          nil -> splitters_hit
          pos -> MapSet.put(splitters_hit, pos)
        end

      simulate(rest ++ new_beams, seen, splitters_hit, grid)
    end
  end

  defp trace_beam({r, c}, grid) do
    rows = length(grid)
    cols = length(Enum.at(grid, 0))
    do_trace(r, c, grid, rows, cols)
  end

  defp do_trace(r, c, grid, rows, cols) do
    next_r = r + 1

    if next_r >= rows do
      # Beam exits the grid
      {[], nil}
    else
      cell = grid |> Enum.at(next_r) |> Enum.at(c)

      if cell == "^" do
        # Hit a splitter - create two new beams
        new_beams =
          [{next_r, c - 1}, {next_r, c + 1}]
          |> Enum.filter(fn {_, col} -> col >= 0 && col < cols end)

        {new_beams, {next_r, c}}
      else
        # Continue moving down
        do_trace(next_r, c, grid, rows, cols)
      end
    end
  end

  # Part 2: Count timelines (distinct paths from position to bottom)
  defp count_timelines(pos, grid, memo) do
    case Map.get(memo, pos) do
      nil ->
        {count, memo} = do_count_timelines(pos, grid, memo)
        {count, Map.put(memo, pos, count)}

      count ->
        {count, memo}
    end
  end

  defp do_count_timelines({r, c}, grid, memo) do
    rows = length(grid)
    cols = length(Enum.at(grid, 0))

    next_r = r + 1

    if next_r >= rows do
      # Particle exits - this is one complete timeline
      {1, memo}
    else
      cell = grid |> Enum.at(next_r) |> Enum.at(c)

      if cell == "^" do
        # Hit splitter - timeline splits into two
        {left_count, memo} =
          if c - 1 >= 0 do
            count_timelines({next_r, c - 1}, grid, memo)
          else
            {0, memo}
          end

        {right_count, memo} =
          if c + 1 < cols do
            count_timelines({next_r, c + 1}, grid, memo)
          else
            {0, memo}
          end

        {left_count + right_count, memo}
      else
        # Continue down in this timeline
        count_timelines({next_r, c}, grid, memo)
      end
    end
  end
end

input = File.read!(Enum.at(System.argv(), 0))
part1 = Day07.solve_part1(input)
part2 = Day07.solve_part2(input)
IO.puts("Part 1: #{part1}")
IO.puts("Part 2: #{part2}")
