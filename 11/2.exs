defmodule BasicMath do
	def gcd(a, 0), do: a
	def gcd(0, b), do: b
	def gcd(a, b), do: gcd(b, rem(a,b))

	def lcm(0, 0), do: 0
	def lcm(a, b), do: (a*b)/gcd(a,b)
end

defmodule ReadMonkeyInfo do
  defp change_monkey(line, monkeys) do
    reg = ~r"Monkey ([0-9]+):"
    [_, current | _] = Regex.run(reg, line)
    current = String.to_integer(current)

    case Map.fetch(monkeys, current) do
      {:ok, monkey} -> {monkey, current}
      :error -> {%{total: 0}, current}
    end
  end

  defp set_starting_items(line, monkey) do
    reg = ~r"Starting items: (.*)"
    [_, items | _] = Regex.run(reg, line)
    items = String.split(items, ",") |> Enum.map(&String.trim/1) |> Enum.map(&String.to_integer/1)
    Map.put(monkey, :items, items)
  end

  defp set_operation(line, monkey) do
    reg = ~r"Operation: new = old (.) (.*)"
    [_, operation, number | _] = Regex.run(reg, line)

    number =
      case Integer.parse(number) do
        {number, _} -> number
        :error -> String.to_atom(number)
      end

    Map.put(monkey, :operation, [operation, number])
  end

  defp set_test(line, monkey) do
    reg = ~r"Test: divisible by ([0-9]+)"
    [_, number | _] = Regex.run(reg, line)
    number = String.to_integer(number)
    Map.put(monkey, :divisible_by, number)
  end

  def set_if(line, monkey) do
    reg = ~r"If (true|false): throw to monkey ([0-9]+)"
    [_, condition, number | _] = Regex.run(reg, line)
    number = String.to_integer(number)

    conditions =
      case Map.fetch(monkey, :if) do
        {:ok, conditions} -> conditions
        :error -> %{}
      end

    conditions = Map.put(conditions, String.to_atom(condition), number)
    Map.put(monkey, :if, conditions)
  end

  def get_monkey_info(line, monkeys, current) do
    {monkey, current} =
      cond do
        String.starts_with?(line, "Monkey") ->
          change_monkey(line, monkeys)

        String.starts_with?(line, "Starting items:") ->
          monkey = set_starting_items(line, monkeys[current])
          {monkey, current}

        String.starts_with?(line, "Operation:") ->
          monkey = set_operation(line, monkeys[current])
          {monkey, current}

        String.starts_with?(line, "Test:") ->
          monkey = set_test(line, monkeys[current])
          {monkey, current}

        String.starts_with?(line, "If") ->
          monkey = set_if(line, monkeys[current])
          {monkey, current}

        true ->
          {nil, nil}
      end

    monkeys =
      if current != nil do
        Map.put(monkeys, current, monkey)
      else
        monkeys
      end

    {monkeys, current}
  end
end

defmodule Round do
  defp operation(item, operation, number) do
    number =
      if number == :old do
        item
      else
        number
      end

    case operation do
      "+" -> item + number
      "*" -> item * number
    end
  end

  defp inspect_item(monkey, item, lcm) do
    # IO.puts(" Inspecting item with worry level #{item}")
    [op, num] = monkey.operation
    item = operation(item, op, num)
    # IO.puts(" Item #{op} #{num} is #{item}")
    item = rem(item, lcm)
    # item = Integer.floor_div(item,3)
    # IO.puts(" Item divided by 3 is #{item}")
    to_monkey =
      if rem(item, monkey.divisible_by) == 0 do
        monkey.if.true
      else
        monkey.if.false
      end

    # IO.puts(" Send item #{item} to #{to_monkey}")
    {item, to_monkey}
  end

  defp monkey_action(monkeys, monkey_num, lcm) do
    monkey = monkeys[monkey_num]
    # IO.puts("Monkey #{monkey_num}:")

    {monkeys, total} =
      for item <- monkey.items, reduce: {monkeys, monkey.total} do
        {monkeys, total} ->
          {item, to_monkey} = inspect_item(monkey, item, lcm)
          new_monkey = monkeys[to_monkey]
          new_monkey = Map.put(new_monkey, :items, new_monkey.items ++ [item])
          {Map.put(monkeys, to_monkey, new_monkey), total + 1}
      end

    new_monkey = Map.put(monkey, :items, [])
    new_monkey = Map.put(new_monkey, :total, total)
    Map.put(monkeys, monkey_num, new_monkey)
  end

  def round(monkeys, lcm) do
    for n <- Map.keys(monkeys), reduce: monkeys do
      monkeys ->
        monkey_action(monkeys, n, lcm)
    end
  end
end

{monkeys, _} =
  File.stream!("input")
  |> Stream.map(&String.trim/1)
  |> Enum.reduce({%{}, 0}, fn line, {monkeys, current} ->
    ReadMonkeyInfo.get_monkey_info(line, monkeys, current)
  end)

divisors = Enum.map(monkeys, fn {_, monkey} -> monkey.divisible_by end)

lcm = Enum.reduce(divisors,0, fn num,acc -> if acc > 0, do: BasicMath.lcm(round(acc),num), else: num end)

lcm = round(lcm)

monkeys =
  Enum.reduce(1..10000, monkeys, fn round, monkeys ->
    # IO.puts("#{round}")
    Round.round(monkeys, lcm)
  end)

monkeys = Enum.map(monkeys, fn {k, monkey} -> {k, monkey.total} end)

monkeys = Enum.sort(monkeys, fn {_, total1}, {_, total2} -> total1 >= total2 end)

[{_, total1}, {_, total2} | _] = monkeys

IO.inspect(total1 * total2)
