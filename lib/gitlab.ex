defmodule Gitlab do
  alias Tanuki.Client
  alias Tanuki.Projects.Repository.Branches
  alias Tanuki.Projects.Repository.Commits

  def listener(callback) do
  end

  def fetch_projects do
    pmap(config(:gitlab_projects), fn(project) ->
      project_id = URI.encode_www_form(project)
      branch = Branches.find(project_id, "master", client)
      commit = Commits.find(project_id, branch.commit.id, client)
      Map.put_new(commit, :project, project)
    end)
  end

  defp pmap(collection, function) do
    collection
    |> Enum.map(&Task.async(fn -> function.(&1) end))
    |> Enum.map(&Task.await(&1))
  end

  defp client do
    Client.new(%{private_token: config(:gitlab_token)}, config(:gitlab_url))
  end

  defp config(key) do
    Application.get_env(:gitlab_ci_monitor, GitlabCiMonitor.Endpoint)[key]
  end
end
