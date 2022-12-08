defmodule M do
  def main do
    f =
      File.read!("input")
      |> String.split("\n")

    results = read_line(f, [], 0)
    results = max3(results, {0, 0, 0})
    IO.inspect(elem(results, 0) + elem(results, 1) + elem(results, 2))
  end

  def read_line([line | lines], results, sum) do
    {sum, results} =
      unless line == "" do
        {num, _} = Integer.parse(line)
        {sum + num, results}
      else
        results = [sum | results]
        {0, results}
      end

    read_line(lines, results, sum)
  end

  def read_line([], results, sum), do: results

  def max3([num | nums], results) do
    results =
      cond do
        num > elem(results, 0) ->
          {num, elem(results, 0), elem(results, 1)}

        num > elem(results, 1) ->
          {elem(results, 0), num, elem(results, 1)}

        num > elem(results, 2) ->
          {elem(results, 0), elem(results, 1), num}

        true ->
          results
      end

    max3(nums, results)
  end

  def max3([], results), do: results
end

M.main()
