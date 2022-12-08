defmodule M do
  def get_priority(str) do
    str = String.to_charlist(str)
    len = (length(str) / 2) |> round
    [a, b | _] = Enum.chunk_every(str, len)

    [c | _] =
      :ordsets.intersection(:ordsets.from_list(a), :ordsets.from_list(b)) |> :ordsets.to_list()

    priority(c)
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
  |> Stream.map(&M.get_priority/1)
  |> Enum.sum()

IO.inspect(res)
