defmodule M do
  def get_direction(d) do
    case d do
      "D" -> :down
      "U" -> :up
      "R" -> :right
      "L" -> :left
    end
  end

  def draw(head) do
    {x, y} = head
    size_x = 50
    size_y = 20
    IO.puts("\e[H\e[2J")

    str =
      for i <- -size_y..size_y, into: "" do
        line =
          for j <- -size_x..size_x, into: "" do
            y = -y

            c =
              case {i, j} do
                {^y, ^x} -> "H"
                {0, 0} -> "0"
                _ -> "."
              end

            c
          end

        line <> "\n"
      end

    IO.puts(str)
    IO.inspect(head)
    Process.sleep(50)
  end

  def follow(head, tail) do
    if
  end

  def move(head, tail, direction, 0), do: head

  def move(head, tail, direction, n) do
    {x, y} = head

    head =
      case direction do
        :left -> {x - 1, y}
        :right -> {x + 1, y}
        :down -> {x, y - 1}
        :up -> {x, y + 1}
      end



    draw(head)
    move(head, direction, n - 1)
  end
end

moves =
  File.stream!("input")
  |> Stream.map(&String.trim/1)
  |> Stream.map(&String.split/1)
  |> Stream.map(fn [d, n | _] -> {M.get_direction(d), String.to_integer(n)} end)
  |> Enum.reduce({{0, 0}, {0, 0}}, fn {dir, n}, head -> M.move(head, dir, n) end)

IO.inspect(moves)
