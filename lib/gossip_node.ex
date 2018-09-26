defmodule GossipNode do
  use GenServer

  def start_link(mParent, mNeighbors, mRcvTimes, mMsg) do
    GenServer.start_link(__MODULE__, {mParent, mNeighbors, mRcvTimes, mMsg}, [])
  end

  def neighbor(server_pid, mNeighborList) do
    GenServer.call(server_pid, {:neighbor, mNeighborList})
  end

  def initiate(server_pid, msg) do
    GenServer.call(server_pid, {:initiate, msg})
  end

  def init({mParent, mNeighbors, mRcvTimes, mMsg}) do
    {:ok, {mParent, mNeighbors, mRcvTimes, mMsg}}
  end

  # Update neighbor list
  def handle_call({:neighbor, mNeighborList}, _from, {mParent, mNeighbors, mRcvTimes, mMsg}) do
    IO.inspect(mNeighborList)
    {:reply, :ok, {mParent, mNeighborList, mRcvTimes, mMsg}}
  end

  # Initiate first msg
  def handle_call({:initiate, msg}, _from, {mParent, mNeighbors, mRcvTimes, mMsg}) do
    sendToRandNeighbor(msg, mNeighbors)
    {:reply, :ok, {mParent, mNeighbors, mRcvTimes, msg}}
  end

  def handle_info({:message, msg}, {mParent, mNeighbors, mRcvTimes, mMsg}) do
    #    IO.puts "#{Kernel.inspect(self())} Received #{msg} #{mRcvTimes + 1} times"
    mRcvTimes = mRcvTimes + 1

    if mRcvTimes == 1 do # Received first time
      send(mParent, :finish)
      scheduleSend()
    end

    if mRcvTimes == 10 do # 10th time
      {:stop, :normal, {mParent, mNeighbors, mRcvTimes, mMsg}}
    else # Continue sending to others
      sendToRandNeighbor(msg, mNeighbors)
      {:noreply, {mParent, mNeighbors, mRcvTimes, msg}}
    end
  end

  def handle_info(:work, {mParent, mNeighbors, mRcvTimes, mMsg}) do
    sendToRandNeighbor(mMsg, mNeighbors)
    scheduleSend()
    {:noreply, {mParent, mNeighbors, mRcvTimes, mMsg}}
  end

  # Send msg to a random neighbor
  defp sendToRandNeighbor(msg, neighbors) do
    randNeighbor = Enum.random(neighbors)
    send randNeighbor, {:message, msg}
    #    IO.puts "#{Kernel.inspect(self())} sends #{msg} to #{Kernel.inspect(randNeighbor)}"
  end

  defp scheduleSend() do
    Process.send_after(self(), :work, 5)
  end
end
