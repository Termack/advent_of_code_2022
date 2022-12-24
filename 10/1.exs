defmodule M do
  def process_cycle(cycle, sum, x, cycles) do
    cycle = cycle + 1

    case cycles do
      [^cycle | cycles] ->
        sum = sum + cycle * x
        {cycle, sum, cycles}

      _ ->
        {cycle, sum, cycles}
    end
  end

  def execute_instruction(instruction, cycle, x, sum, cycles) do
    {cycle, sum, cycles} = process_cycle(cycle, sum,x, cycles)

    case instruction do
      [_, n | []] -> addx(String.to_integer(n), cycle, x, sum, cycles)
      _ -> {cycle, x, sum, cycles}
    end
  end

  def addx(n, cycle, x, sum, cycles) do
    x = x + n
    {cycle, sum, cycles} = process_cycle(cycle, sum, x, cycles)
    {cycle, x, sum, cycles}
  end
end

{_, _, sum, _} = File.stream!("input")
|> Stream.map(&String.split/1)
|> Enum.reduce({1, 1, 0, [20, 60, 100, 140, 180, 220]}, fn instruction, {cycle, x, sum, cycles} ->
  M.execute_instruction(instruction, cycle, x, sum, cycles)
end)

IO.inspect(sum)
