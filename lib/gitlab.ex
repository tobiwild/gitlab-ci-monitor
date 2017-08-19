defmodule Gitlab do
  use Confex, otp_app: :gitlab_ci_monitor

  alias Tanuki.Client
  alias Tanuki.Projects.Repository.Commits
  alias Tanuki.Projects

  def fetch_commits do
    pmap(config()[:projects], fn(project) ->
      project_id = URI.encode_www_form(project)
      commit = Commits.find(project_id, "master", client())

      {
        project,
        %{
          status: commit[:status],
          commit_author: commit[:author_name],
          commit_message: commit[:message],
          commit_created_at: commit[:created_at],
          commit_sha: commit[:id],
          pipelines: case commit[:status] do
            nil -> [] # there are no pipelines when status is null
            _ -> fetch_running_pipelines(project)
          end
        }
      }
    end) |> Enum.into(%{})
  end

  def fetch_running_pipelines(project_id) do
    Tanuki.get("projects/#{URI.encode_www_form(project_id)}/pipelines?status=running&ref=master", client())
    |> pmap(fn pipeline -> fetch_pipeline(project_id, pipeline[:id]) end)
  end

  def fetch_pipeline(project, id) do
    project_id = URI.encode_www_form(project)
    pipeline = Tanuki.get("projects/#{project_id}/pipelines/#{id}", client())
    commit = Commits.find(project_id, pipeline[:sha], client())

    %{
      created_at: pipeline[:updated_at],
      commit_author: commit[:author_name],
      commit_message: commit[:message],
      commit_created_at: commit[:created_at],
      commit_sha: commit[:id]
    }
  end

  def fetch_projects do
    pmap(config()[:projects], fn(project_id) ->
      project = Projects.find(URI.encode_www_form(project_id), client())

      {
        project_id,
        %{
          :id => project_id,
          :name => project[:name_with_namespace],
          :image => parse_image(project)
        }
      }
    end) |> Enum.into(%{})
  end

  def fetch_statistics do
    pmap(config()[:projects], fn(project) ->
      project_id = URI.encode_www_form(project)
      duration = Tanuki.get("projects/#{project_id}/pipelines?status=success&ref=master&per_page=5", client())
      |> pmap(fn pipeline -> Tanuki.get("projects/#{project_id}/pipelines/#{pipeline[:id]}", client()) end)
      |> Enum.filter(fn p -> p[:duration] != nil end)
      |> Enum.map(fn p -> p[:duration] end)
      |> average

      {
        project,
        %{
          :duration => duration
        }
      }
    end) |> Enum.into(%{})
  end

  def validate_config!(conf) do
    conf = Enum.into(conf, %{})
    case conf[:projects] do
      p when is_binary(p) ->
        %{conf | projects: String.split(p, ",")}
      _ -> conf
    end
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

  defp pmap(collection, function) do
    collection
    |> Enum.map(&Task.async(fn -> function.(&1) end))
    |> Enum.map(&Task.await/1)
  end

  defp client do
    Client.new(%{private_token: config()[:token]}, config()[:url])
  end
end
