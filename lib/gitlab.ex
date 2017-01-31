defmodule Gitlab do
  use Confex, otp_app: :gitlab_ci_monitor

  alias Tanuki.Client
  alias Tanuki.Projects.Repository.Branches
  alias Tanuki.Projects.Repository.Commits
  alias Tanuki.Projects

  def fetch_commits do
    pmap(config()[:projects], fn(project) ->
      project_id = URI.encode_www_form(project)
      branch = Branches.find(project_id, "master", client())
      commit = Commits.find(project_id, branch.commit.id, client())

      {
        project,
        %{
          :status => commit[:status],
          :last_commit_author => commit[:author_name],
          :last_commit_message => commit[:message],
          :updated_at => commit[:created_at],
          :pipelines => case commit[:status] do
            "running" -> fetch_pipelines(project)
            _ -> []
          end
        }
      }
    end) |> Enum.into(%{})
  end

  def fetch_pipelines(project_id) do
    Tanuki.get("projects/#{URI.encode_www_form(project_id)}/builds?scope=running", client())
    |> Enum.filter(fn build -> build[:ref] == "master" end)
    |> Enum.map(fn build -> build[:pipeline][:id] end)
    |> Enum.uniq
    |> pmap(fn id -> fetch_pipeline(project_id, id) end)
  end

  def fetch_pipeline(project_id, id) do
    pipeline = Tanuki.get("projects/#{URI.encode_www_form(project_id)}/pipelines/#{id}", client())
    %{
      created_at: pipeline[:updated_at]
    }
  end

  def fetch_projects do
    pmap(config()[:projects], fn(project_id) ->
      project = Projects.find(URI.encode_www_form(project_id), client())

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
    pmap(config()[:projects], fn(project_id) ->
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

  def validate_config(conf) do
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

  defp list_pipelines(project_id) do
    Tanuki.get("projects/#{URI.encode_www_form(project_id)}/pipelines", client())
  end

  defp pmap(collection, function) do
    collection
    |> Enum.map(&Task.async(fn -> function.(&1) end))
    |> Enum.map(&Task.await/1)
  end

  defp client do
    Client.new(%{private_token: config()[:token]}, config()[:url])
  end
end
