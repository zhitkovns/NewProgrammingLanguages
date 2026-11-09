defmodule PageRank do
  def start_node(id, initial_rank) do
    spawn_link(fn -> node_loop(id, initial_rank, 0.0) end)
  end

  defp node_loop(id, rank, acc) do
    receive do
      {:contribute, amount} ->
        node_loop(id, rank, acc + amount)
      {:compute, neighbors, d, n, coordinator} ->
        new_rank = (1.0 - d) / n + d * acc
        send(coordinator, {:new_rank, id, new_rank})

        if length(neighbors) > 0 do
          share = new_rank / length(neighbors)
          Enum.each(neighbors, fn neighbor -> send(neighbor, {:contribute, share}) end)
        end

        node_loop(id, new_rank, 0.0)
    end
  end

  def run do
    n = 4
    d = 0.85
    threshold = 0.0001

    graph = %{
      1 => [2],
      2 => [3],
      3 => [1, 4],
      4 => [2]
    }

    nodes = Map.new(graph, fn {id, _} -> {id, start_node(id, 1.0 / n)} end)
    pids = Map.new(nodes, fn {id, pid} -> {id, pid} end)

    pid_graph = Map.new(graph, fn {id, neighbors} ->
      {id, Enum.map(neighbors, fn n_id -> Map.fetch!(pids, n_id) end)}
    end)

    iterate(pid_graph, nodes, d, n, threshold, 1, %{})
  end

  defp iterate(pid_graph, nodes, d, n, threshold, iter, prev_ranks) do
    Enum.each(pid_graph, fn {id, neighbors} ->
      pid = Map.fetch!(nodes, id)
      send(pid, {:compute, neighbors, d, n, self()})
    end)

    new_ranks = collect_ranks(Map.keys(nodes), %{})
    
    diff = if iter == 1 do
      1.0
    else
      Enum.reduce(new_ranks, 0.0, fn {id, rank}, max_diff ->
        old_rank = Map.fetch!(prev_ranks, id)
        max(max_diff, abs(rank - old_rank))
      end)
    end

    IO.puts("Iteration #{iter}: max diff = #{Float.round(diff, 6)}")

    if diff > threshold do
      iterate(pid_graph, nodes, d, n, threshold, iter + 1, new_ranks)
    else
      IO.puts("Converged after #{iter} iterations.")
      print_ranks(new_ranks)
    end
  end

  defp collect_ranks([], acc), do: acc
  defp collect_ranks([_ | rest], acc) do
    receive do
      {:new_rank, id, rank} ->
        collect_ranks(rest, Map.put(acc, id, rank))
    end
  end

  defp print_ranks(ranks) do
    IO.puts("Final PageRank values:")
    Enum.each(Enum.sort(ranks), fn {id, rank} ->
      IO.puts("Node #{id}: #{Float.round(rank, 4)}")
    end)
  end
end

PageRank.run()