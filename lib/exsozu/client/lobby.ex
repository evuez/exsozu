defmodule ExSozu.Client.Lobby do
  @moduledoc false

  defstruct [lobby: %{}, queue: :queue.new(), size: 0]

  @max_size 1_000
  @eviction_rate 200

  def start_link,
    do: Agent.start_link(fn -> %__MODULE__{} end, name: __MODULE__)

  def put(id, client) do
    Agent.update(__MODULE__, fn state ->
      state = if state.size + 1 > @max_size do
        # Drops older clients before reaching @max_size.
        # The eviction rate is constant so it's pretty dumb since once it's full it'll
        # be full again every @eviction_rate call to put/2.
        # Also dropping clients just because the queue is full is nonsense but I can't
        # think of any other solution for now (not knowing the expected number of answers
        # from Sōzu).
        {evicted, queue} = :queue.split(@eviction_rate, state.queue)
        lobby = Map.drop(state.lobby, :queue.to_list(evicted))
        %{state | lobby: lobby, queue: queue, size: state.size - @eviction_rate}
      else
        state
      end

      %{state |
        lobby: Map.put(state.lobby, id, client),
        queue: :queue.in(id, state.queue),
        size: state.size + 1} # Drop elems if new size > @max_size
    end)
  end

  def get(id), do: Agent.get(__MODULE__, &Map.get(&1.lobby, id))
end
