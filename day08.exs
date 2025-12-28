#!/usr/bin/env elixir

defmodule UnionFind do
  @moduledoc """
  Union-Find (Disjoint Set Union) data structure with path compression
  and union by size for efficient connected component tracking.
  """

  defstruct parent: %{}, size: %{}

  def new(elements) do
    %UnionFind{
      parent: Map.new(elements, fn e -> {e, e} end),
      size: Map.new(elements, fn e -> {e, 1} end)
    }
  end

  def find(%UnionFind{parent: parent} = uf, x) do
    case Map.get(parent, x) do
      ^x -> {x, uf}
      px ->
        {root, uf} = find(uf, px)
        # Path compression: make x point directly to root
        {root, %{uf | parent: Map.put(uf.parent, x, root)}}
    end
  end

  def union(%UnionFind{} = uf, x, y) do
    {root_x, uf} = find(uf, x)
    {root_y, uf} = find(uf, y)

    if root_x == root_y do
      # Already in same set
      {false, uf}
    else
      # Union by size: attach smaller tree under larger tree
      size_x = Map.get(uf.size, root_x)
      size_y = Map.get(uf.size, root_y)

      {new_root, old_root} =
        if size_x >= size_y, do: {root_x, root_y}, else: {root_y, root_x}

      new_size = size_x + size_y

      uf = %{
        uf
        | parent: Map.put(uf.parent, old_root, new_root),
          size: Map.put(uf.size, new_root, new_size)
      }

      {true, uf}
    end
  end

  def component_sizes(%UnionFind{} = uf, elements) do
    {roots, _uf} =
      Enum.reduce(elements, {[], uf}, fn elem, {roots, uf} ->
        {root, uf} = find(uf, elem)
        {[root | roots], uf}
      end)

    roots
    |> Enum.frequencies()
    |> Map.values()
  end
end

defmodule Day08 do
  def solve_part1(input, num_connections) do
    points = parse_points(input)

    # Generate all pairs with their distances
    edges = generate_edges(points)

    # Sort by distance
    sorted_edges = Enum.sort_by(edges, fn {_i, _j, dist} -> dist end)

    # Initialize Union-Find
    indices = 0..(length(points) - 1) |> Enum.to_list()
    uf = UnionFind.new(indices)

    # Process the first num_connections pairs (edges)
    uf_final =
      sorted_edges
      |> Enum.take(num_connections)
      |> Enum.reduce(uf, fn {i, j, _dist}, uf ->
        {_connected, new_uf} = UnionFind.union(uf, i, j)
        new_uf
      end)

    # Get component sizes
    sizes = UnionFind.component_sizes(uf_final, indices)

    # Get three largest and multiply
    sizes
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.reduce(1, &*/2)
  end

  def solve_part2(input) do
    points = parse_points(input)

    # Generate all pairs with their distances
    edges = generate_edges(points)

    # Sort by distance
    sorted_edges = Enum.sort_by(edges, fn {_i, _j, dist} -> dist end)

    # Initialize Union-Find
    indices = 0..(length(points) - 1) |> Enum.to_list()
    uf = UnionFind.new(indices)

    # Keep connecting until we have only 1 component
    # Track the last connection that actually united two components
    num_points = length(points)

    {_uf_final, last_connection} =
      Enum.reduce_while(sorted_edges, {uf, num_points, nil}, fn {i, j, _dist}, {uf, num_components, _last} ->
        {connected, new_uf} = UnionFind.union(uf, i, j)

        if connected do
          new_num_components = num_components - 1

          if new_num_components == 1 do
            # All connected! This is the last connection we need
            {:halt, {new_uf, {i, j}}}
          else
            {:cont, {new_uf, new_num_components, {i, j}}}
          end
        else
          {:cont, {uf, num_components, nil}}
        end
      end)

    # Get the X coordinates of the last two junction boxes connected
    {i, j} = last_connection
    {x1, _y1, _z1} = Enum.at(points, i)
    {x2, _y2, _z2} = Enum.at(points, j)

    x1 * x2
  end

  defp parse_points(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end

  defp generate_edges(points) do
    indexed_points = Enum.with_index(points)

    for {p1, i} <- indexed_points,
        {p2, j} <- indexed_points,
        i < j do
      dist = distance(p1, p2)
      {i, j, dist}
    end
  end

  defp distance({x1, y1, z1}, {x2, y2, z2}) do
    dx = x1 - x2
    dy = y1 - y2
    dz = z1 - z2
    :math.sqrt(dx * dx + dy * dy + dz * dz)
  end
end

input = File.read!(Enum.at(System.argv(), 0))
part1 = Day08.solve_part1(input, 1000)
part2 = Day08.solve_part2(input)
IO.puts("Part 1: #{part1}")
IO.puts("Part 2: #{part2}")
