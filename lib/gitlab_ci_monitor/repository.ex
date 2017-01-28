defmodule GitlabCiMonitor.Repository do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def projects do
    GenServer.call(__MODULE__, :projects)
  end

  def update(key, items) do
    GenServer.cast(__MODULE__, {:update, key, items})
  end

  def has_items?(key) do
    GenServer.call(__MODULE__, {:has_items, key})
  end

  def handle_call({:has_items, key}, _from, state) do
    {:reply, Map.has_key?(state, key), state}
  end

  def handle_call(:projects, _from, state) do
    {
      :reply,
      state
      |> Map.values
      |> Enum.reduce(%{}, fn items, acc ->
        MapUtils.deep_merge(acc, items)
      end)
      |> Map.values
      |> Enum.sort_by(fn (p) -> p[:updated_at] end, &>=/2),
      state
    }
  end

  def handle_info(:notify, state) do
    GenEvent.notify(:gitlab_event_manager, :update)
    {:noreply, state}
  end

  def handle_cast({:update, key, items}, state) do
    if Map.has_key?(state, key) and state[key] != items do
      send self(), :notify
    end

    {:noreply, Map.put(state, key, items)}
  end
end
