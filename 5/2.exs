defmodule M do
  def get_stacks(numbers) do
    for _ <- String.split(numbers), do: []
  end

  def fill_stacks(stacks, [crates | crates_tail]) do
    crates = String.codepoints(crates)
    stacks = fill_stack(crates, stacks, [])
    fill_stacks(stacks, crates_tail)
  end

  def fill_stacks(stacks, []), do: stacks

  def fill_stack([" ", " ", " " | crates], [stack | stacks], results) do
    [_ | crates] = crates
    fill_stack(crates, stacks, [stack | results])
  end

  def fill_stack(["[", crate, "]" | crates], [stack | stacks], results) do
    [_ | crates] = crates
    stack = [crate | stack]
    fill_stack(crates, stacks, [stack | results])
  end

  def fill_stack([], [], results), do: Enum.reverse(results)

  def move(stacks, _, _, 0), do: stacks

  def move(stacks, from, to, n) do
    {head,tail} = Enum.split(stacks[from],n)

    {_, stacks} =
      Map.replace(stacks, from, tail)
      |> Map.get_and_update!(to, fn stack -> {stack, head ++ stack} end)

    stacks
  end

  def read_move(stacks, []), do: stacks
  def read_move(stacks, [move | moves]) do
    reg = ~r"move ([0-9]+) from ([0-9]) to ([0-9])"
    [_,n,from,to|_] = Regex.run(reg, move)
    from = String.to_integer(from)
    to = String.to_integer(to)
    n = String.to_integer(n)
    stacks = move(stacks,from,to,n) |> read_move(moves)
    stacks
  end
end

{crates, moves} =
  File.stream!("input")
  |> Enum.split_while(&(&1 !== "\n"))

[numbers | crates] = Enum.reverse(crates)

stacks = M.get_stacks(numbers) |> M.fill_stacks(crates)

stacks = for {v, i} <- Enum.with_index(stacks), into: %{}, do: {i+1, v}

[_ | moves] = moves

stacks = M.read_move(stacks, moves)

result = for {_,stack} <- stacks, into: "", do: List.first(stack)

IO.inspect(result)
