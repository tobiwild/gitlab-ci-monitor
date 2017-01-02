defmodule GitlabCiMonitor do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(GitlabCiMonitor.Endpoint, []),
      # Start your own worker by calling: GitlabCiMonitor.Worker.start_link(arg1, arg2, arg3)
      # worker(GitlabCiMonitor.Worker, [arg1, arg2, arg3]),
      worker(GenEvent, [[name: :gitlab_event_manager]])
    ]

    children = children ++ Enum.map(GitlabCiMonitor.Repository.servers, fn server ->
      worker(server, [])
    end)

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GitlabCiMonitor.Supervisor]
    with {:ok, pid} <- Supervisor.start_link(children, opts),
        :ok <- GenEvent.add_handler(:gitlab_event_manager, GitlabCiMonitor.EventManager, nil),
      do: {:ok, pid}
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    GitlabCiMonitor.Endpoint.config_change(changed, removed)
    :ok
  end
end
