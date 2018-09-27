defmodule Proj2 do
  def start(mAlgo, mTopo, mNumNode) do
    actorList = for i <- 1..mNumNode  do
      {:ok, pid} = GossipNode.start_link(self(), [], 0, [])
#      {:ok, pid} = PushSumNode.start_link(self(), [], i, 1, {})
      pid
    end

    lineNetwork(actorList)

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

  defp threeDNetwork(actorList) do
    for i <- actorList do
      list = for j <- actorList, j != i do
        j
      end
      GossipNode.neighbor(i, list)
    end
  end
end
