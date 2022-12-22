defmodule M do
  def get_direction(d) do
    case d do
      "D" -> :down
      "U" -> :up
      "R" -> :right
      "L" -> :left
    end
  end

  def draw(head, tail, moves) do
    {x1, y1} = head
    tails =  Stream.zip(tail, 1..length(tail)) |> Enum.into(%{})
    size_x = 50
    size_y = 30
    IO.puts("\e[H\e[2J")

    str =
      for i <- -size_y..size_y, into: "" do
        line =
          for j <- -size_x..size_x, into: "" do
            c =
              cond do
                {-i, j} == {y1, x1} -> "H"
                Map.has_key?(tails, {j, -i}) -> "T"
                {i, j} == {0, 0} -> "0"
                Map.has_key?(moves, {j, -i}) -> "#"
                true -> "."
              end

            c
          end

        line <> "\n"
      end

    IO.puts(str)
    IO.inspect(head)
    # IO.inspect(tail)
    Process.sleep(50)
  end

  def is_far({x1, y1}, {x2, y2}) do
    abs(x1 - x2) > 1 or abs(y1 - y2) > 1
  end

  def get_closer(a, b) do
    cond do
      a > b -> b + 1
      a < b -> b - 1
      true -> b
    end
  end

  def follow(last, []), do: {[],last}
  def follow(head, [tail|tails]) do
    tail = if is_far(head, tail) do
      {x1, y1} = head
      {x2, y2} = tail
      x2 = get_closer(x1, x2)
      y2 = get_closer(y1, y2)

      {x2, y2}
    else
      tail
    end
    {tails,result} = follow(tail, tails)
    {[tail| tails],result}
  end

  def move(head, tail, moves, _, 0), do: {head, tail, moves}

  def move(head, tail, moves, direction, n) do
    {x, y} = head

    # IO.inspect(head)

    head =
      case direction do
        :left -> {x - 1, y}
        :right -> {x + 1, y}
        :down -> {x, y - 1}
        :up -> {x, y + 1}
      end

    {tail,last} = follow(head, tail)
    moves = Map.put(moves, last, :ok)
    # draw(head,tail, moves)
    move(head, tail, moves, direction, n - 1)
  end
end

{_, _, moves} =
  File.stream!("input")
  |> Stream.map(&String.trim/1)
  |> Stream.map(&String.split/1)
  |> Stream.map(fn [d, n | _] -> {M.get_direction(d), String.to_integer(n)} end)
  |> Enum.reduce(
    {{0, 0}, [{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}], %{}},
    fn {dir, n}, {head, tail, moves} -> M.move(head, tail, moves, dir, n) end
  )

IO.inspect(map_size(moves))
