defmodule GitlabCiMonitor.EventManager do
  use GenEvent

  def handle_event(:update, _) do
    GitlabCiMonitorWeb.GitlabChannel.broadcast_projects
    {:ok, nil}
  end
end
