defmodule ChannelMap do
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, %{}, [name: name])
  end

  def put(bucket, key, value) do
    # Send the server a :put "instruction"
    GenServer.call(bucket, {:put, key, value})
  end

  def fetch(bucket, key) do
    GenServer.call(bucket, {:fetch, key})
  end

  def length(bucket) do
    GenServer.call(bucket, :length)
  end

  def delete(bucket, key) do
    GenServer.call(bucket, {:delete, key})
  end

  def handle_call({:put, key, value}, _from, state) do
    {:reply, :ok, Map.put(state, key, value)}
  end

  def handle_call({:fetch, key}, _from, state) do
    {:reply, Map.fetch(state, key), state}
  end

  def handle_call(:length, _from, state) do
    {:reply, Kernel.map_size(state), state}
  end

  def handle_call({:delete, key}, _from, state) do
    {:reply, :ok, Map.delete(state, key)}
  end

  def init(map) do
    {:ok, map}
  end
end
