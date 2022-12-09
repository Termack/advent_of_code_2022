defmodule M do
  def matrix_get(matrix, x, y) do
    elem(matrix, y) |> elem(x)
  end

  def check_trees(matrix, result, x, y, max, fun) do
    tree_size = matrix_get(matrix, x, y)

    {max, result} =
      if tree_size > max, do: {tree_size, Map.put(result, {x, y}, :exists)}, else: {max, result}

    case fun.(x, y, max) do
      {x, y, max} -> check_trees(matrix, result, x, y, max, fun)
      :stop -> result
    end
  end
end

matrix =
  File.stream!("input")
  |> Stream.map(&String.trim/1)
  |> Stream.map(fn string ->
    list = for char <- String.codepoints(string), do: String.to_integer(char)
    List.to_tuple(list)
  end)
  |> Enum.to_list()
  |> List.to_tuple()

max_x = tuple_size(elem(matrix, 0))
max_y = tuple_size(matrix)

result = %{}

result =
  M.check_trees(matrix, result, 0, 0, -1, fn x, y, max ->
    {x, y, max} = if x + 1 < max_x, do: {x + 1, y, max}, else: {0, y + 1, -1}
    if y < max_y, do: {x, y, max}, else: :stop
  end)

result =
  M.check_trees(matrix, result, max_x - 1, 0, -1, fn x, y, max ->
    {x, y, max} = if x - 1 >= 0, do: {x - 1, y, max}, else: {max_x - 1, y + 1, -1}
    if y < max_y, do: {x, y, max}, else: :stop
  end)

result =
  M.check_trees(matrix, result, 0, 0, -1, fn x, y, max ->
    {x, y, max} = if y + 1 < max_y, do: {x, y + 1, max}, else: {x + 1, 0, -1}
    if x < max_x, do: {x, y, max}, else: :stop
  end)

result =
  M.check_trees(matrix, result, 0, max_y - 1, -1, fn x, y, max ->
    {x, y, max} = if y - 1 >= 0, do: {x, y - 1, max}, else: {x + 1, max_y - 1, -1}
    if x < max_x, do: {x, y, max}, else: :stop
  end)

IO.inspect(map_size(result))
