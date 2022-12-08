defmodule M do
  def find_4_different([head | tail], last, acc) do
    if length(last) == 4 and last -- Enum.uniq(last) == [] do
      acc
    else
      last = [head | Enum.take(last, 3)]
      find_4_different(tail, last, acc + 1)
    end
  end
end

num = File.read!("input") |> String.codepoints() |> M.find_4_different([], 0)

IO.inspect(num)
