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

      def init(state) do
        if GitlabCiMonitor.Repository.has_items?(__MODULE__) do
          schedule_work()
        else
          send self(), :update
        end
        {:ok, state}
      end

      def handle_info(:update, state) do
        GitlabCiMonitor.Repository.update(
          __MODULE__,
          update(state)
        )
        schedule_work()

        {:noreply, state}
      end

      defp schedule_work() do
        Process.send_after(self(), :update, update_after())
      end
    end
  end

end
