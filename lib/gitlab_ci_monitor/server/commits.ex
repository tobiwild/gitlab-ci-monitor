defmodule GitlabCiMonitor.Server.Statistics do
  use GitlabCiMonitor.Server

  def update(_) do
    Gitlab.fetch_statistics
  end

  def update_after() do
    120 * 1000
  end
end
