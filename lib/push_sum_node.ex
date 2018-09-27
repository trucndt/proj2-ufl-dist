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
    GenServer.call(server_pid, :initiate)
  end

  def init({mParent, mNeighbors, s, w, past}) do
    {:ok, {mParent, mNeighbors, s, w, past}}
  end

  # Update neighbor list
  def handle_call({:neighbor, mNeighborList}, _from, {mParent, mNeighbors, s, w, past}) do
    IO.inspect(mNeighborList)
    {:reply, :ok, {mParent, mNeighborList, s, w, past}}
  end

  # Initiate first msg
  def handle_call(:initiate, _from, {mParent, mNeighbors, s, w, past}) do
    sendToRandNeighbor({s/2, w/2}, mNeighbors)
    {:reply, :ok, {mParent, mNeighbors, s/2, w/2, past}}
  end

  def handle_info({:message, msg}, {mParent, mNeighbors, s, w, past}) do
    {recvS, recvW} = msg
    IO.puts "#{Kernel.inspect(self())} Received S = #{recvS}, W = #{recvW}"
#    IO.puts("S = #{recvS}, W = #{recvW}")

    if is_integer(s) && w === 1 do # Received first time
      IO.puts "#{Kernel.inspect(self())} First time"
      scheduleSend()
    end

    s = s + recvS
    w = w + recvW

    sendToRandNeighbor({s/2, w/2}, mNeighbors)

    ratio = s/w

    if tuple_size(past) < 2 do
      if tuple_size(past) < 1 do
        {:noreply, {mParent, mNeighbors, s/2, w/2, {ratio}}}
      else
        {lastRatio} = past
        {:noreply, {mParent, mNeighbors, s/2, w/2, {abs(ratio - lastRatio), ratio}}}
      end
    else
      {lastDiff, lastRatio} = past
      IO.puts("#{Kernel.inspect(self())} LastDiff = #{lastDiff} , lastRario = #{lastRatio}, curRatio = #{ratio}")
      if lastDiff < 1.0e-10 && abs(ratio - lastRatio) < 1.0e-10 do
        IO.puts("#{Kernel.inspect(self())} diff = #{abs(ratio - lastRatio)}")
        send(mParent, :finish)
        {:stop, :normal, {mParent, mNeighbors, s/2, w/2, {abs(ratio - lastRatio), ratio}}}
      else
        {:noreply, {mParent, mNeighbors, s/2, w/2, {abs(ratio - lastRatio), ratio}}}
      end
    end

  end

  def handle_info(:work, {mParent, mNeighbors, s, w, past}) do
    sendToRandNeighbor({s/2, w/2}, mNeighbors)

    ratio = s/w
    {lastDiff, lastRatio} = past
    IO.puts("#{Kernel.inspect(self())} LastDiff = #{lastDiff} , lastRario = #{lastRatio}")
    if lastDiff < 1.0e-10 && abs(ratio - lastRatio) < 1.0e-10 do
      IO.puts("#{Kernel.inspect(self())} diff = #{abs(ratio - lastRatio)}")
      send(mParent, :finish)
      {:stop, :normal, {mParent, mNeighbors, s/2, w/2, {abs(ratio - lastRatio), ratio}}}
    else
      scheduleSend()
      {:noreply, {mParent, mNeighbors, s/2, w/2, {abs(ratio - lastRatio), ratio}}}
    end
  end

  # Send msg to a random neighbor
  defp sendToRandNeighbor(msg, neighbors) do
    randNeighbor = Enum.random(neighbors)
    send randNeighbor, {:message, msg}
    {recvS, recvW} = msg
    IO.puts "#{Kernel.inspect(self())} sends S = #{recvS}, W = #{recvW} to #{Kernel.inspect(randNeighbor)}"
  end

  defp scheduleSend() do
    Process.send_after(self(), :work, 10)
  end
end
