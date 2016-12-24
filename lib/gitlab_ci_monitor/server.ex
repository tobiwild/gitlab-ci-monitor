defmodule GitlabCiMonitor.Server do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: GitlabServer)
  end

  def projects do
    GenServer.call(GitlabServer, :projects)
  end

  def init(state) do
    send self, :update
    {:ok, state}
  end

  def handle_info(:update, state) do
    state = Gitlab.fetch_projects
    schedule_work()
    {:noreply, state}
  end

  def handle_call(:projects, _from, state) do
    {:reply, state, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :update, 30 * 1000)
  end
end
