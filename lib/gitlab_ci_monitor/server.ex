defmodule GitlabCiMonitor.Server do

  @callback update(state :: term) :: new_state :: term
  @callback update_after() :: mirco_sec :: term

  defmacro __using__(_) do
    quote location: :keep do
      use GenServer
      @behaviour GitlabCiMonitor.Server

      def start_link do
        GenServer.start_link(__MODULE__, nil, name: __MODULE__)
      end

      def items do
        GenServer.call(__MODULE__, :items)
      end

      def init(state) do
        send self, :update
        {:ok, state}
      end

      def handle_info(:update, state) do
        new_state = update(state)
        schedule_work()

        if state != nil and new_state != state do
          send self, :notify
        end

        {:noreply, new_state}
      end

      def handle_info(:notify, state) do
        GenEvent.notify(:gitlab_event_manager, :update)
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
