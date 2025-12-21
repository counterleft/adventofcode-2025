#!/usr/bin/env elixir

defmodule Day06 do
  @doc """
  Part 1: Solves all problems on the cephalopod math worksheet.
  Returns the grand total (sum of all problem answers).
  """
  def part1(input) do
    lines = parse_input(input)

    # Transpose to work with columns
    columns = transpose(lines)

    # Group columns into problems (separated by all-space columns)
    problems = group_into_problems(columns)

    # Solve each problem and sum
    problems
    |> Enum.map(&solve_problem/1)
    |> Enum.sum()
  end

  @doc """
  Part 2: Solves all problems reading right-to-left.
  Each column is one number (read top-to-bottom for digits).
  """
  def part2(input) do
    lines = parse_input(input)

    # Transpose to work with columns
    columns = transpose(lines)

    # Group columns into problems (separated by all-space columns)
    problems = group_into_problems(columns)

    # Solve each problem (reading right-to-left) and sum
    problems
    |> Enum.map(&solve_problem_rtl/1)
    |> Enum.sum()
  end

  # Transposes rows into columns
  defp transpose(lines) do
    # Find max width
    max_width = Enum.map(lines, &String.length/1) |> Enum.max(fn -> 0 end)

    # Pad all lines to same width
    padded = Enum.map(lines, fn line ->
      String.pad_trailing(line, max_width)
    end)

    # Transpose: convert rows to columns
    for col <- 0..(max_width - 1) do
      Enum.map(padded, fn line -> String.at(line, col) end)
      |> Enum.join()
    end
  end

  # Groups consecutive non-separator columns into problems
  defp group_into_problems(columns) do
    columns
    |> Enum.chunk_by(&all_spaces?/1)
    |> Enum.reject(fn group -> all_spaces?(hd(group)) end)
  end

  # Checks if a string contains only spaces
  defp all_spaces?(str) do
    String.trim(str) == ""
  end

  # Solves a single problem (group of columns)
  defp solve_problem(column_group) do
    # Combine the columns back into rows for this problem
    num_rows = String.length(hd(column_group))

    rows = for row_idx <- 0..(num_rows - 1) do
      Enum.map(column_group, fn col -> String.at(col, row_idx) end)
      |> Enum.join()
      |> String.trim()
    end

    # Last row is the operator, others are numbers
    {number_rows, [operator]} = Enum.split(rows, -1)

    # Parse numbers (filter out empty strings)
    nums = number_rows
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&String.to_integer/1)

    # Apply operation
    case operator do
      "+" -> Enum.sum(nums)
      "*" -> Enum.reduce(nums, 1, &*/2)
    end
  end

  # Solves a problem reading right-to-left (Part 2)
  # Each column is one number, read top-to-bottom
  defp solve_problem_rtl(column_group) do
    # Reverse to read right-to-left
    reversed_columns = Enum.reverse(column_group)

    num_rows = String.length(hd(reversed_columns))
    operator_row_idx = num_rows - 1

    # Extract operator and numbers
    {operator, nums} = Enum.reduce(reversed_columns, {nil, []}, fn col, {op, nums_acc} ->
      # Check if this column has the operator
      op_char = String.at(col, operator_row_idx)
      new_op = if op_char in ["+", "*"], do: op_char, else: op

      # Extract the number from this column (rows 0 to operator_row_idx - 1)
      digits = for row_idx <- 0..(operator_row_idx - 1) do
        String.at(col, row_idx)
      end
      |> Enum.join()
      |> String.trim()

      new_nums = if digits == "" do
        nums_acc
      else
        [String.to_integer(digits) | nums_acc]
      end

      {new_op, new_nums}
    end)

    # Reverse nums to get them in the right order
    nums = Enum.reverse(nums)

    # Apply operation
    case operator do
      "+" -> Enum.sum(nums)
      "*" -> Enum.reduce(nums, 1, &*/2)
    end
  end

  @doc """
  Parses input into a list of strings (one per row).
  """
  def parse_input(input) do
    input
    |> String.trim_trailing()
    |> String.split("\n")
  end

  def main do
    input = case System.argv() do
      [filename] -> File.read!(filename)
      [] ->
        case IO.read(:stdio, :eof) do
          :eof ->
            IO.puts("Usage: ./day06.exs <input_file>")
            System.halt(1)
          data -> data
        end
    end

    IO.puts("Part 1: #{part1(input)}")
    IO.puts("Part 2: #{part2(input)}")
  end
end

unless System.get_env("ELIXIR_TEST_MODE") == "true" do
  Day06.main()
end
