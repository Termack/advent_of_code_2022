defmodule M do
  def process_cycle(cycle, _, current, []), do: {cycle, current, []}

  def process_cycle(cycle, x, current, cycles) do
    [next | rest] = cycles

    pixel = cycle - current

    if pixel >= x && pixel <= x + 2 do
      IO.write("#")
    else
      IO.write(".")
    end

    {current, cycles} =
      if next == cycle do
        IO.write("\n")
        {next, rest}
      else
        {current, cycles}
      end

    cycle = cycle + 1

    {cycle, current, cycles}
  end

  def execute_instruction(instruction, cycle, x, current, cycles) do
    {cycle, current, cycles} = process_cycle(cycle, x, current, cycles)

    case instruction do
      [_, n | []] -> addx(String.to_integer(n), cycle, x, current, cycles)
      _ -> {cycle, x, current, cycles}
    end
  end

  def addx(n, cycle, x, current, cycles) do
    {cycle, current, cycles} = process_cycle(cycle, x, current, cycles)
    x = x + n
    {cycle, x, current, cycles}
  end
end

File.stream!("input")
|> Stream.map(&String.split/1)
|> Enum.reduce({1, 1, 0, [40, 80, 120, 160, 200, 240]}, fn instruction,
                                                           {cycle, x, current, cycles} ->
  M.execute_instruction(instruction, cycle, x, current, cycles)
end)
