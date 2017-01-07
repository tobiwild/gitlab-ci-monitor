defmodule Gitlab do
  alias Tanuki.Client
  alias Tanuki.Projects.Repository.Branches
  alias Tanuki.Projects.Repository.Commits
  alias Tanuki.Projects

  def fetch_commits do
    pmap(config(:gitlab_projects), fn(project) ->
      project_id = URI.encode_www_form(project)
      branch = Branches.find(project_id, "master", client)
      commit = Commits.find(project_id, branch.commit.id, client)

      {
        project,
        %{
          :status => commit[:status],
          :last_commit_author => commit[:author_name],
          :last_commit_message => commit[:message],
          :updated_at => commit[:created_at]
        }
      }
    end) |> Enum.into(%{})
  end

  def fetch_projects do
    pmap(config(:gitlab_projects), fn(project_id) ->
      project = Projects.find(URI.encode_www_form(project_id), client)

      {
        project_id,
        %{
          :name => project[:name_with_namespace],
          :image => parse_image(project)
        }
      }
    end) |> Enum.into(%{})
  end

  def fetch_statistics do
    pmap(config(:gitlab_projects), fn(project_id) ->
      duration = list_pipelines(project_id)
      |> Stream.filter(fn p -> p[:ref] == "master" end)
      |> Stream.filter(fn p -> p[:status] == "success" end)
      |> Stream.filter(fn p -> p[:duration] != nil end)
      |> Stream.map(fn p -> p[:duration] end)
      |> Enum.to_list
      |> average

      {
        project_id,
        %{
          :duration => duration
        }
      }
    end) |> Enum.into(%{})
  end

  defp parse_image(project = %{:avatar_url => nil}) do
    Exgravatar.gravatar_url(
      project[:name_with_namespace],
      s: 80,
      d: "identicon",
      f: "y"
    )
  end
  defp parse_image(project), do: project[:avatar_url]

  defp average([]), do: 0
  defp average(list), do: Enum.sum(list) / length(list)

  defp list_pipelines(project_id) do
    Tanuki.get("projects/#{URI.encode_www_form(project_id)}/pipelines", client)
  end

  defp pmap(collection, function) do
    collection
    |> Enum.map(&Task.async(fn -> function.(&1) end))
    |> Enum.map(&Task.await/1)
  end

  defp client do
    Client.new(%{private_token: config(:gitlab_token)}, config(:gitlab_url))
  end

  defp config(key) do
    Application.get_env(:gitlab_ci_monitor, GitlabCiMonitor.Endpoint)[key]
  end
end
