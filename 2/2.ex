defmodule M do
  def points(choice) do
    case choice do
      :rock -> 1
      :paper -> 2
      :scissors -> 3
    end
  end

  def options do
    %{rock: :scissors, paper: :rock, scissors: :paper}
  end

  def convert(letter) do
    case letter do
      x when x in ["A", "X"] ->
        :rock

      x when x in ["B", "Y"] ->
        :paper

      x when x in ["Z", "C"] ->
        :scissors
    end
  end

  def play(player1, player2) do
    options = options()

    cond do
      Map.fetch!(options, player1) == player2 ->
        6

      Map.fetch!(options, player2) == player1 ->
        0

      true ->
        3
    end
  end

  def read_line([line | lines], score) do
    [opponent, you] = String.split(line)
    opponent = convert(opponent)
    you = convert(you)
    result = play(you, opponent)
    IO.inspect(score)
    read_line(lines, score + result + points(you))
  end

  def read_line([], score), do: score
end

f =
  File.read!("input")
  |> String.split("\n")

result = M.read_line(f, 0)
IO.inspect(result)
