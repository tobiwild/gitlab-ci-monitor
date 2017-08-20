use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :gitlab_ci_monitor, GitlabCiMonitorWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
                    cd: Path.expand("../assets", __DIR__)]]

config :gitlab_ci_monitor, Gitlab,
  url: {:system, "GITLAB_URL", "http://gitlab.local/api/v4"},
  token: {:system, "GITLAB_TOKEN", "y4xiykbq5jhQPzbf-3vR"},
  projects: {:system, "GITLAB_PROJECTS", [
    "root/test",
    "root/test2",
    "root/test3",
    "root/test4"
  ]},
  commits_interval: {:system, :integer,"GITLAB_COMMITS_INTERVAL", 10},
  projects_interval: {:system, :integer, "GITLAB_PROJECTS_INTERVAL", 10},
  statistics_interval: {:system, :integer, "GITLAB_STATISTICS_INTERVAL", 10}

# Watch static and templates for browser reloading.
config :gitlab_ci_monitor, GitlabCiMonitorWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/gitlab_ci_monitor_web/views/.*(ex)$},
      ~r{lib/gitlab_ci_monitor_web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20
