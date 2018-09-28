defmodule Proj2 do
  def start(mAlgo, mTopo, mNumNode) do
    actorList = for i <- 1..mNumNode  do
      {:ok, pid} = cond do
        mAlgo == "gossip" ->
          GossipNode.start_link(self(), [], 0, [])
        mAlgo == "push-sum" ->
          PushSumNode.start_link(self(), [], i, 1, {})
      end
      pid
    end

    cond do
      mTopo == "full" ->
        fullNetwork(actorList, mAlgo)
      mTopo == "3D" ->
         threeDNetwork(actorList, mAlgo)
      mTopo == "rand2D" ->
         rand2DNetwork(actorList, mAlgo)
      mTopo == "sphere" ->
        sphereNetwork(actorList, mAlgo)
      mTopo == "line" ->
        lineNetwork(actorList, mAlgo)
      mTopo == "imp2D" ->
        impLineNetwork(actorList, mAlgo)
    end

    cond do
      mAlgo == "gossip" ->
        GossipNode.initiate(Enum.at(actorList, 0), "John 3:16")
      mAlgo == "push-sum" ->
        Enum.each(actorList, fn actor -> PushSumNode.initiate(actor) end)
    end

    time = :timer.tc(fn  -> waitForWorkers(mNumNode) end) |> elem(0) |> Kernel./(1_000)

    IO.puts("Elapsed time = #{time}")
  end

  defp waitForWorkers(noActors) do
    if noActors > 0 do
      receive do
        :finish -> waitForWorkers(noActors - 1)
      end
    end
  end

  defp fullNetwork(actorList, mAlgo) do
    for i <- actorList do
      list = for j <- actorList, j != i do
        j
      end
      if mAlgo == "gossip", do: GossipNode.neighbor(i, list), else: PushSumNode.neighbor(i, list)
    end
  end

  defp lineNetwork(actorList, mAlgo) do
    for i <- 0 .. length(actorList) - 1  do
      list = cond do
        i == 0 ->
          [Enum.at(actorList, i + 1)]
        i == length(actorList) - 1 ->
          [Enum.at(actorList, i - 1)]
        true ->
          [Enum.at(actorList, i - 1), Enum.at(actorList, i + 1)]
      end
      if mAlgo == "gossip", do: GossipNode.neighbor(Enum.at(actorList, i), list), else: PushSumNode.neighbor(Enum.at(actorList, i), list)
    end
  end

  defp impLineNetwork(actorList, mAlgo) do
    for i <- 0 .. length(actorList) - 1  do
      list = cond do
        i == 0 ->
          [Enum.at(actorList, i + 1)]
        i == length(actorList) - 1 ->
          [Enum.at(actorList, i - 1)]
        true ->
          [Enum.at(actorList, i - 1), Enum.at(actorList, i + 1)]
      end

      list = [otherRandNeighbor(actorList, list) | list]
      if mAlgo == "gossip", do: GossipNode.neighbor(Enum.at(actorList, i), list), else: PushSumNode.neighbor(Enum.at(actorList, i), list)
    end
  end

  # Find a random neighbor that have not appeared in *list*
  defp otherRandNeighbor(actorList, list) do
    if (neighbor = Enum.random(actorList)) in list do
      otherRandNeighbor(actorList, list)
    else
      neighbor
    end
  end

  defp threeDNetwork(actorList, mAlgo) do
    size = 4*4
    one_size = trunc(:math.sqrt(size))

    for i <- 0 .. length(actorList) - 1  do
      list = []
      list = if i - 1 >=  one_size * div(i, one_size) do
        [Enum.at(actorList, i - 1) | list]
      else
        list
      end

      list = if i + 1 < one_size * (div(i, one_size) + 1) do
        [Enum.at(actorList, i + 1) | list]
      else
        list
      end

      list = if i - one_size >= size * div(i, size) do
        [Enum.at(actorList, i - one_size) | list]
      else
        list
      end

      list = if i + one_size < size * (div(i, size) + 1) do
        [Enum.at(actorList, i + one_size) | list]
      else
        list
      end

      list = if i - size >= 0 do
        [Enum.at(actorList, i - size) | list]
      else
        list
      end

      list = if i + size < length(actorList) do
        [Enum.at(actorList, i + size) | list]
      else
        list
      end

      if mAlgo == "gossip", do: GossipNode.neighbor(Enum.at(actorList, i), list), else: PushSumNode.neighbor(Enum.at(actorList, i), list)
    end
  end

  defp sphereNetwork(actorList, mAlgo) do
    one_size = 4

    for i <- 0 .. length(actorList) - 1  do
      list = []
      list = if i - 1 >=  one_size * div(i, one_size) do
        [Enum.at(actorList, i - 1) | list]
      else
        [Enum.at(actorList, i + one_size - 1) | list]
      end

      list = if i + 1 < one_size * (div(i, one_size) + 1) do
        [Enum.at(actorList, i + 1) | list]
      else
        [Enum.at(actorList, i - one_size + 1) | list]
      end

      list = if i - one_size >= 0 do
        [Enum.at(actorList, i - one_size) | list]
      else
        [Enum.at(actorList, div(length(actorList) - 1, one_size) * one_size + i) | list]
      end

      list = if i + one_size < length(actorList) do
        [Enum.at(actorList, i + one_size) | list]
      else
        [Enum.at(actorList, rem(i, one_size)) | list]
      end

      if mAlgo == "gossip", do: GossipNode.neighbor(Enum.at(actorList, i), list), else: PushSumNode.neighbor(Enum.at(actorList, i), list)
    end
  end

  defp rand2DNetwork(actorList, mAlgo) do
    coor = for i <- actorList do
      {:rand.uniform(), :rand.uniform()}
    end

    for i <- 0..length(actorList) - 1 do
      list = for j <- 0..length(actorList) - 1, j != i, calcDistance(Enum.at(coor, i), Enum.at(coor, j)) < 0.1 do
        Enum.at(actorList, j)
      end

      if mAlgo == "gossip", do: GossipNode.neighbor(Enum.at(actorList, i), list), else: PushSumNode.neighbor(Enum.at(actorList, i), list)
    end
  end

  defp calcDistance({x1, y1}, {x2, y2}) do
    dx = x1 - x2
    dy = y1 - y2
    :math.sqrt(dx * dx + dy * dy)
  end
end
