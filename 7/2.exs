defmodule M do
  def handle_commands([], filesystem, size), do: {[], filesystem, size}

  def handle_commands([command | commands], filesystem, size) do
    cond do
      String.starts_with?(command, "$") ->
        [_, command | path] = String.split(command)

        result = exec_command(command, path, commands, filesystem, size)

        case result do
          :return -> {commands, Map.put(filesystem, :size, size), size}
          {commands, filesystem, size} -> handle_commands(commands, filesystem, size)
        end

      String.starts_with?(command, "dir") ->
        [_, dir | _] = String.split(command)
        handle_commands(commands, Map.put(filesystem, dir, %{}), size)

      true ->
        [file_size, file | _] = String.split(command)
        file_size = String.to_integer(file_size)
        filesystem = Map.update(filesystem, :size, 0, &(&1 + file_size))
        handle_commands(commands, Map.put(filesystem, file, file_size), size + file_size)
    end
  end

  def exec_command(command, path, commands, filesystem, size) do
    case command do
      "cd" ->
        [path | _] = path

        case path do
          "/" ->
            {commands, filesystem, size} = handle_commands(commands, filesystem, 0)
            {commands, Map.put(filesystem, :size, size), size}

          ".." ->
            :return

          _ ->
            dir = filesystem[path]
            {commands, dir, new_size} = handle_commands(commands, dir, 0)
            {commands, Map.put(filesystem, path, dir), size + new_size}
        end

      "ls" ->
        {commands, filesystem, size}

      _ ->
        raise "error"
    end
  end
end

defmodule MapReduce do
  def list_over_n(map, acc, key, n) do
    Enum.reduce(map, acc, fn
      {k, v}, acc when k == key ->
        if v >= n, do: [v | acc], else: acc

      {_, %{} = v}, acc ->
        MapReduce.list_over_n(v, acc, key,n)

      _, acc ->
        acc
    end)
  end
end

{_, filesystem, _} =
  File.stream!("input")
  |> Stream.map(&String.trim/1)
  |> Enum.to_list()
  |> M.handle_commands(%{}, 0)

# IO.inspect(filesystem)

total = 70000000
needed = 30000000

used = filesystem[:size]

need_delete = needed - (total - used)

min = MapReduce.list_over_n(filesystem, [], :size, need_delete) |> Enum.min()

IO.inspect(min)
