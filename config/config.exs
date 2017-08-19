# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :gitlab_ci_monitor, GitlabCiMonitorWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "M+DP1PJccEqZzmfJNAO5JGhzAeM73vjCKHlvXRa4a745/5vBGWAH7x2u5nnBaeTx",
  render_errors: [view: GitlabCiMonitorWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: GitlabCiMonitorWeb.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
