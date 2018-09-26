defmodule Proj2 do
  def start(mAlgo, mTopo, mNumNode) do
    actorList = for i <- 1..mNumNode  do
      {:ok, pid} = GossipNode.start_link(self(), [], 0)
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
end

defmodule GossipNode do
  use GenServer

  def start_link(mParent, mNeighbors, mRcvTimes) do
    GenServer.start_link(__MODULE__, {mParent, mNeighbors, mRcvTimes}, [])
  end

  def neighbor(server_pid, mNeighborList) do
    GenServer.call(server_pid, {:neighbor, mNeighborList})
  end

  def initiate(server_pid, msg) do
    GenServer.call(server_pid, {:initiate, msg})
  end

  def init({mParent, mNeighbors, mRcvTimes}) do
    {:ok, {mParent, mNeighbors, mRcvTimes}}
  end

  # Update neighbor list
  def handle_call({:neighbor, mNeighborList}, _from, {mParent, mNeighbors, mRcvTimes}) do
    IO.inspect(mNeighborList)
    {:reply, :ok, {mParent, mNeighborList, mRcvTimes}}
  end

  # Initiate first msg
  def handle_call({:initiate, msg}, _from, {mParent, mNeighbors, mRcvTimes}) do
    randNeighbor = Enum.random(mNeighbors) # Generate random neighbor
    IO.puts("Choosen neighbor: #{inspect(randNeighbor)}")
    send randNeighbor, msg
    {:reply, :ok, {mParent, mNeighbors, mRcvTimes}}
  end

  def handle_info(msg, {mParent, mNeighbors, mRcvTimes}) do
    IO.puts "#{Kernel.inspect(self())} Received #{msg} #{mRcvTimes + 1} times"
    mRcvTimes = mRcvTimes + 1

    if mRcvTimes == 1 do # Received first time
      send(mParent, :finish)
    end

    if mRcvTimes == 10 do # 10th time
      {:stop, :normal, {mParent, mNeighbors, mRcvTimes}}
    else # Continue sending to others
      randNeighbor = Enum.random(mNeighbors)
      send randNeighbor, msg
      IO.puts "#{Kernel.inspect(self())} sends #{msg} to #{Kernel.inspect(randNeighbor)}"
      {:noreply, {mParent, mNeighbors, mRcvTimes}}
    end
  end
end


