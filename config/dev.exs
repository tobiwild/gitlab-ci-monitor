use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :gitlab_ci_monitor, GitlabCiMonitor.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
                    cd: Path.expand("../", __DIR__)]]

config :gitlab_ci_monitor, Gitlab,
  url: "http://gitlab.local/api/v4",
  token: "y4xiykbq5jhQPzbf-3vR",
  projects: [
    "root/test",
    "root/test2",
    "root/test3"
  ],
  commits_interval: 10,
  projects_interval: 10,
  statistics_interval: 10

# Watch static and templates for browser reloading.
config :gitlab_ci_monitor, GitlabCiMonitor.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20
