defmodule M do
  def find_4_different([head|tail], last, acc, n) do
    if length(last) == n and last -- Enum.uniq(last) == [] do
      acc
    else
      last = [head|Enum.take(last,n-1)]
      find_4_different(tail, last, acc+1,n)
    end
  end
end

num =
  File.read!("input") |> String.codepoints() |> M.find_4_different([],0,14)

IO.inspect(num)
