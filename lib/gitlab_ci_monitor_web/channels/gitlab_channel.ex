defmodule GitlabCiMonitorWeb.GitlabChannel do
  use GitlabCiMonitorWeb, :channel

  def join("gitlab:lobby", payload, socket) do
    if authorized?(payload) do
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(:after_join, socket) do
    push socket, "projects", %{list: GitlabCiMonitor.Repository.projects}
    {:noreply, socket}
  end

  def broadcast_projects do
    GitlabCiMonitorWeb.Endpoint.broadcast("gitlab:lobby", "projects", %{list: GitlabCiMonitor.Repository.projects})
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (gitlab:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
