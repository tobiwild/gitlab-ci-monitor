defmodule GitlabCiMonitor.Repository do
  def projects do
    Enum.reduce(servers, %{}, fn server, acc ->
      MapUtils.deep_merge(acc, server.items)
    end) |> Map.values
  end

  def servers do
    [
      GitlabCiMonitor.Server.Projects,
      GitlabCiMonitor.Server.Commits,
      GitlabCiMonitor.Server.Statistics
    ]
  end
end
