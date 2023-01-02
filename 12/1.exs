defmodule Bfs do
  def get_valid_neighbors(matrix, {x, y}) do
    current = M.matrix_get(matrix, {x, y})

    Enum.filter([{x - 1, y}, {x + 1, y}, {x, y + 1}, {x, y - 1}], fn neighbor ->
      case M.matrix_get(matrix, neighbor) do
        :error ->
          false

        value ->
          value <= current + 1
      end
    end)
  end

  def bfs(matrix, start, target) do
    find_path(matrix, target, :queue.in(start, :queue.new()), %{start => :visited}, %{})
  end

  def draw(matrix, target, visited, previous, current, neighbors) do
    IO.puts("\e[H\e[2J")

    str =
      for y <- 0..(map_size(matrix) - 1), into: "" do
        line =
          for x <- 0..(map_size(matrix[y]) - 1), into: "" do
            c =
              cond do
                {x, y} == target ->
                  "X"

                {x, y} == current ->
                  "."

                Enum.member?(neighbors, {x, y}) ->
                  "#"

                Map.has_key?(previous, {x, y}) ->
                  prev = previous[{x, y}]

                  cond do
                    prev == {x - 1, y} -> "<"
                    prev == {x + 1, y} -> ">"
                    prev == {x, y - 1} -> "^"
                    prev == {x, y + 1} -> "v"
                  end

                Map.has_key?(visited, {x, y}) ->
                  " "

                true ->
                  <<M.matrix_get(matrix, {x, y})>>
                  # true -> "."
              end

            c
          end

        line <> "\n"
      end

    IO.puts(str)
    Process.sleep(20)
  end

  def find_path(matrix, target, queue, visited, previous) do
    case :queue.out(queue) do
      {{:value, current}, queue} ->
        # draw(matrix, target, visited, previous, current, get_valid_neighbors(matrix, current))

        if current != target do
          {visited, queue, previous} =
            for neighbor <- get_valid_neighbors(matrix, current),
                reduce: {visited, queue, previous} do
              {visited, queue, previous} ->
                case Map.fetch(visited, neighbor) do
                  :error ->
                    visited = Map.put(visited, neighbor, :visited)
                    queue = :queue.in(neighbor, queue)
                    previous = Map.put(previous, neighbor, current)
                    {visited, queue, previous}

                  _ ->
                    {visited, queue, previous}
                end
            end

          find_path(matrix, target, queue, visited, previous)
        else
          previous
        end
      {:empty,_} -> previous
    end
  end
end

defmodule M do
  def matrix_get(matrix, {x, y}) do
    case Map.fetch(matrix, y) do
      :error ->
        :error

      {:ok, row} ->
        case Map.fetch(row, x) do
          :error -> :error
          {:ok, val} -> val
        end
    end
  end

  def update_matrix(matrix, {x, y}, value) do
    row = matrix[y]
    row = Map.put(row, x, value)
    Map.put(matrix, y, row)
  end

  def find_start_and_end(matrix) do
    for y <- 0..(map_size(matrix) - 1), reduce: {matrix, {0, 0}, {0, 0}} do
      {matrix, start, target} ->
        for x <- 0..(map_size(Map.fetch!(matrix, y)) - 1), reduce: {matrix, start, target} do
          {matrix, start, target} ->
            case matrix_get(matrix, {x, y}) do
              ?S -> {update_matrix(matrix, {x, y}, ?a), {x, y}, target}
              ?E -> {update_matrix(matrix, {x, y}, ?z), start, {x, y}}
              _ -> {matrix, start, target}
            end
        end
    end
  end

  def get_path(previous, target, result) do
    case Map.fetch(previous,target) do
      :error -> result
      {:ok, value} -> get_path(previous, value, [target|result])
    end
  end
end

matrix =
  File.stream!("input")
  |> Stream.map(&String.trim/1)
  |> Stream.map(fn string ->
    string |> String.to_charlist() |> Enum.with_index() |> Map.new(fn {k, v} -> {v, k} end)
  end)
  |> Enum.with_index()
  |> Map.new(fn {k, v} -> {v, k} end)

{matrix, start, target} = M.find_start_and_end(matrix)

previous = Bfs.bfs(matrix, start, target)

IO.inspect(length(M.get_path(previous, target, [])))
