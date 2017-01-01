defmodule GitlabCiMonitor.Server do

  @callback update(state :: term) :: new_state :: term
  @callback update_after() :: mirco_sec :: term

  defmacro __using__(_) do
    quote location: :keep do
      use GenServer
      @behaviour GitlabCiMonitor.Server

      def start_link do
        GenServer.start_link(__MODULE__, [], name: __MODULE__)
      end

      def items do
        GenServer.call(__MODULE__, :items)
      end

      def init(state) do
        send self, :update
        {:ok, state}
      end

      def handle_info(:update, state) do
        state = update(state)
        schedule_work()
        {:noreply, state}
      end

      def handle_call(:items, _from, state) do
        {:reply, state, state}
      end

      defp schedule_work() do
        Process.send_after(self(), :update, update_after())
      end
    end
  end

end
