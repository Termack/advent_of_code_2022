defmodule M do
  def matrix_get(matrix, x, y) do
    elem(matrix, y) |> elem(x)
  end

  def get_scores(matrix, result, x, y) do
    max_x = tuple_size(elem(matrix, 0))
    max_y = tuple_size(matrix)

    tree_size = matrix_get(matrix, x, y)

    score = get_score(matrix, tree_size, 0, x, y, fn x, y ->
      if x + 1 < max_x, do: {x + 1, y}, else: :stop
    end)
    score = score * get_score(matrix, tree_size, 0, x, y, fn x, y ->
      if x - 1 >= 0, do: {x - 1, y}, else: :stop
    end)
    score = score * get_score(matrix, tree_size, 0, x, y, fn x, y ->
      if y + 1 < max_y, do: {x, y+1}, else: :stop
    end)
    score = score * get_score(matrix, tree_size, 0, x, y, fn x, y ->
      if y - 1 >= 0, do: {x, y-1}, else: :stop
    end)

    result = [score| result]

    {x, y} = if x + 1 < max_x, do: {x + 1, y}, else: {0, y + 1}
    if y < max_y, do: get_scores(matrix, result, x, y), else: result
  end

  def get_score(matrix, tree, acc, x, y, fun) do
    case fun.(x, y) do
      {x, y} ->
        if matrix_get(matrix, x, y) < tree do
          get_score(matrix, tree, acc + 1, x, y, fun)
        else
          acc + 1
        end
      :stop -> acc
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

result =
  M.get_scores(matrix, [], 0, 0)

IO.inspect(Enum.max(result))
