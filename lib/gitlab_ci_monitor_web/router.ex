defmodule GitlabCiMonitorWeb.Router do
  use GitlabCiMonitorWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GitlabCiMonitorWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", GitlabCiMonitorWeb do
  #   pipe_through :api
  # end
end
