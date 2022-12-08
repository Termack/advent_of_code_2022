defmodule M do
  def get_priority(line_group) do
    line_group = Enum.map(line_group, &String.to_charlist/1)
    [a, b, c | _] = line_group

    inter =
      :ordsets.intersection(:ordsets.from_list(a), :ordsets.from_list(b)) |> :ordsets.to_list()

    [res | _] =
      :ordsets.intersection(:ordsets.from_list(inter), :ordsets.from_list(c))
      |> :ordsets.to_list()

    priority(res)
  end

  def priority(char) do
    cond do
      char > 97 ->
        char - 96

      char > 65 ->
        char - 64 + 26
    end
  end
end

res =
  File.stream!("input")
  |> Stream.map(&String.trim/1)
  |> Stream.chunk_every(3)
  |> Stream.map(&M.get_priority/1)
  |> Enum.sum()

IO.inspect(res)
