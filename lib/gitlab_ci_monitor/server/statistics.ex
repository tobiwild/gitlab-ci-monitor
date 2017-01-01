defmodule GitlabCiMonitor.Server.Commits do
  use GitlabCiMonitor.Server

  def update(_) do
    Gitlab.fetch_commits
  end

  def update_after() do
    30 * 1000
  end
end
