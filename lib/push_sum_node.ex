defmodule PushSumNode do
  @moduledoc false
  use GenServer

  def start_link(mParent, mNeighbors, s, w, past) do
    GenServer.start_link(__MODULE__, {mParent, mNeighbors, s, w, past}, [])
  end

  def neighbor(server_pid, mNeighborList) do
    GenServer.call(server_pid, {:neighbor, mNeighborList})
  end

  def initiate(server_pid) do
    GenServer.cast(server_pid, :initiate)
  end

  def init({mParent, mNeighbors, s, w, past}) do
    {:ok, {mParent, mNeighbors, s, w, {s/w}}}
  end

  # Update neighbor list
  def handle_call({:neighbor, mNeighborList}, _from, {mParent, mNeighbors, s, w, past}) do
#    IO.inspect(mNeighborList)
    {:reply, :ok, {mParent, mNeighborList, s, w, past}}
  end

  # Initiate first msg
  def handle_cast(:initiate, {mParent, mNeighbors, s, w, past}) do
    sendToRandNeighbor({s/2, w/2}, mNeighbors)
    {:noreply, {mParent, mNeighbors, s/2, w/2, past}}
  end

  # Receving message
  def handle_info({:message, msg}, {mParent, mNeighbors, s, w, past}) do
    {recvS, recvW} = msg

    s = s + recvS
    w = w + recvW

    sendToRandNeighbor({s/2, w/2}, mNeighbors)

    ratio = s/w

    if tuple_size(past) < 2 do
      {lastRatio} = past
      {:noreply, {mParent, mNeighbors, s/2, w/2, {abs(ratio - lastRatio), ratio}}}
    else
      {lastDiff, lastRatio} = past
      if lastDiff < 1.0e-10 && abs(ratio - lastRatio) < 1.0e-10 do
#                IO.puts("#{Kernel.inspect(self())} lastRatio = #{lastRatio}")
        send(mParent, :finish)
        {:noreply, {mParent, mNeighbors, s/2, w/2, {abs(ratio - lastRatio), ratio}}}
      else
        {:noreply, {mParent, mNeighbors, s/2, w/2, {abs(ratio - lastRatio), ratio}}}
      end
    end
  end

  # Send msg to a random neighbor
  defp sendToRandNeighbor(msg, neighbors) do
    if (neighbors != []) do
      randNeighbor = Enum.random(neighbors)
      send randNeighbor, {:message, msg}
    end
  end
end
