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
    scheduleSend()
    {:noreply, {mParent, mNeighbors, s/2, w/2, past}}
  end

  # Receving message
  def handle_info({:message, msg}, {mParent, mNeighbors, s, w, past}) do
    {recvS, recvW} = msg

    if is_integer(s) && w === 1 do # Received first time
#      IO.puts "#{Kernel.inspect(self())} First time"
      scheduleSend()
    end

    s = s + recvS
    w = w + recvW

    sendToRandNeighbor({s/2, w/2}, mNeighbors)

    {:noreply, {mParent, mNeighbors, s/2, w/2, past}}
  end

  # Periodic
  def handle_info(:work, {mParent, mNeighbors, s, w, past}) do
#    sendToRandNeighbor({s/2, w/2}, mNeighbors)

    ratio = s/w
    if tuple_size(past) < 2 do
      {lastRatio} = past
      scheduleSend()
      {:noreply, {mParent, mNeighbors, s/2, w/2, {abs(ratio - lastRatio), ratio}}}
    else
      {lastDiff, lastRatio} = past
      IO.puts("#{Kernel.inspect(self())} LastDiff = #{lastDiff} , lastRatio = #{lastRatio}")
      if lastDiff < 1.0e-10 && abs(ratio - lastRatio) < 1.0e-10 do
        IO.puts("#{Kernel.inspect(self())} diff = #{abs(ratio - lastRatio)}")
        send(mParent, :finish)
        {:stop, :normal, {mParent, mNeighbors, s/2, w/2, {abs(ratio - lastRatio), ratio}}}
      else
        scheduleSend()
        {:noreply, {mParent, mNeighbors, s/2, w/2, {abs(ratio - lastRatio), ratio}}}
      end
    end


  end

  # Send msg to a random neighbor
  defp sendToRandNeighbor(msg, neighbors) do
    if (neighbors != []) do
      randNeighbor = Enum.random(neighbors)
      send randNeighbor, {:message, msg}
#      {recvS, recvW} = msg
#      IO.puts "#{Kernel.inspect(self())} sends S = #{recvS}, W = #{recvW} to #{Kernel.inspect(randNeighbor)}"
    end
  end

  defp scheduleSend() do
    Process.send_after(self(), :work, 5)
  end
end
