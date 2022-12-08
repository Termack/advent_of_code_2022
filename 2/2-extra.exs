defmodule M do
  def points(choice) do
    case choice do
      :rock -> 1
      :paper -> 2
      :scissors -> 3
    end
  end

  @win %{rock: :scissors, paper: :rock, scissors: :paper}
  @lose %{rock: :paper, paper: :scissors, scissors: :rock}
  @outcomes %{"X" => :lose, "Y" => :draw, "Z" => :win}

  def get_choice(opponent, outcome) do
    outcome = @outcomes[outcome]

    case outcome do
      :win -> @lose[opponent]
      :draw -> opponent
      :lose -> @win[opponent]
    end
  end

  def convert(letter) do
    case letter do
      "A" ->
        :rock

      "B" ->
        :paper

      "C" ->
        :scissors
    end
  end

  def play(player1, player2) do
    cond do
      @win[player1] == player2 ->
        6

      @win[player2] == player1 ->
        0

      true ->
        3
    end
  end

  def read_line([line | lines], score) do
    [opponent, you] = String.split(line)
    opponent = convert(opponent)
    you = get_choice(opponent, you)
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
