defmodule M do
  def check_interval(interval) do
    interval =
      Enum.map(interval, fn x ->
        {x, ""} = Integer.parse(x)
        x
      end)

    [a, b, c, d | _] = interval

    (a <= c and b >= d) or (a >= c and b <= d)
  end
end

res =
  File.stream!("input")
  |> Stream.map(&String.trim/1)
  |> Stream.map(fn x -> String.split(x, [",", "-"]) end)
  |> Stream.filter(&M.check_interval/1)
  |> Enum.count()

IO.inspect(res)
