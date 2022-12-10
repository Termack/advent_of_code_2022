size = 10

Enum.each(-size..size,fn _ -> IO.write("\r") end)

for i <- -size..size do
  for j <- -size..size do
    IO.write(".")
  end
  IO.write("\n")
end

IO.puts("\e[H\e[2J")

IO.write("blaaaa")

Enum.each(-size..size,fn _ -> IO.write("\r") end)

IO.write("blaaaa")
