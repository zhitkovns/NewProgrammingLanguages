defmodule Fork do
  def start(id) do
    spawn(fn -> free(id) end)
  end

  defp free(id) do
    receive do
      {:take, from} ->
        send(from, {:ok, self()})
        held(id)
    end
  end

  defp held(id) do
    receive do
      :release ->
        free(id)
    end
  end
end

defmodule Philosopher do
  def start(id, left_fork, right_fork, meals) do
    spawn(fn -> think(id, left_fork, right_fork, meals) end)
  end

  defp think(_id, _lf, _rf, 0) do
    :ok
  end

  defp think(id, lf, rf, remaining) do
    Process.sleep(Enum.random(5..20))
    # philosopher 5 takes forks in reverse order to break the circular wait
    {first, second} = if id == 5, do: {rf, lf}, else: {lf, rf}

    send(first, {:take, self()})

    receive do
      {:ok, _} ->
        send(second, {:take, self()})

        receive do
          {:ok, _} ->
            IO.puts("philosopher #{id} eating, meals left: #{remaining - 1}")
            Process.sleep(Enum.random(5..20))
            send(first, :release)
            send(second, :release)
            think(id, lf, rf, remaining - 1)
        end
    end
  end
end

fork_pids = for id <- 1..5, do: Fork.start(id)
forks = List.to_tuple(fork_pids)

for i <- 1..5 do
  left = elem(forks, rem(i - 1, 5))
  right = elem(forks, rem(i, 5))
  Philosopher.start(i, left, right, 2)
end

Process.sleep(3000)
IO.puts("simulation finished")