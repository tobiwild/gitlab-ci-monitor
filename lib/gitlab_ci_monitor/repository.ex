defmodule GitlabCiMonitor.Repository do
  def projects do
    Enum.reduce(servers, %{}, fn server, acc ->
      MapUtils.deep_merge(acc, server.items)
    end) |> Map.values |> Enum.sort_by(fn (p) -> p[:updated_at] end, &>=/2)
  end

  def servers do
    [
      GitlabCiMonitor.Server.Projects,
      GitlabCiMonitor.Server.Commits,
      GitlabCiMonitor.Server.Statistics
    ]
  end
end
