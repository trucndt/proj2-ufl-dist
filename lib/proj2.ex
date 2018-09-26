defmodule Proj2 do
  def start(mAlgo, mTopo, mNumNode) do
    actorList = for i <- 1..mNumNode  do
      {:ok, pid} = GossipNode.start_link(self(), [], 0, [])
      pid
    end

    fullNetwork(actorList)

    GossipNode.initiate(Enum.at(actorList, 0), "John 3:16")

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
