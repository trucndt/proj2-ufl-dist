defmodule Proj2 do
  def start(mAlgo, mTopo, mNumNode) do
    actorList = for i <- 1..mNumNode  do
      {:ok, pid} = GossipNode.start_link(self(), [], 0, [])
#      {:ok, pid} = PushSumNode.start_link(self(), [], i, 1, {})
      pid
    end

    impLineNetwork(actorList)

    GossipNode.initiate(Enum.at(actorList, 0), "John 3:16")
#    Enum.each(actorList, fn actor -> PushSumNode.initiate(actor) end)
    waitForWorkers(mNumNode)

    IO.puts("DONE")
  end

  defp waitForWorkers(noActors) do
    if noActors > 0 do
      receive do
        :finish -> waitForWorkers(noActors - 1)
      end
    end
  end

  defp fullNetwork(actorList) do
    for i <- actorList do
      list = for j <- actorList, j != i do
        j
      end
      GossipNode.neighbor(i, list)
#      PushSumNode.neighbor(i, list)
    end
  end

  defp lineNetwork(actorList) do
    for i <- 0 .. length(actorList) - 1  do
      list = cond do
        i == 0 ->
          [Enum.at(actorList, i + 1)]
        i == length(actorList) - 1 ->
          [Enum.at(actorList, i - 1)]
        true ->
          [Enum.at(actorList, i - 1), Enum.at(actorList, i + 1)]
      end
      GossipNode.neighbor(Enum.at(actorList, i), list)
    end
  end

  defp impLineNetwork(actorList) do
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
      GossipNode.neighbor(Enum.at(actorList, i), list)
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

  defp threeDNetwork(actorList) do
    SIZE = 4*4
    ONE_SIZE = trunc(:math.sqrt(SIZE))

    for i <- 0 .. length(actorList) - 1  do
      list = if i - 1 >= 0 do
        [list | [Enum.at(actorList, i - 1)]]
      end

      list = if i + 1 < ONE_SIZE do
        [list | [Enum.at(actorList, i + 1)]]
      end

      list = if i - ONE_SIZE >= 0 do
        [list | [Enum.at(actorList, i - ONE_SIZE)]]
      end

      list = if i + ONE_SIZE < SIZE do
        [list | [Enum.at(actorList, i + ONE_SIZE)]]
      end

#      list = if i - 1 >= 0 do
#        [list | [Enum.at(actorList, i - 1)]]
#      end
#
#      list = if i - 1 >= 0 do
#        [list | [Enum.at(actorList, i - 1)]]
#      end
      GossipNode.neighbor(Enum.at(actorList, i), list)
    end
  end
end
