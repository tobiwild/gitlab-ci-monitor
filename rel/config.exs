# Import all plugins from `rel/plugins`
# They can then be used by adding `plugin MyPlugin` to
# either an environment, or release definition, where
# `MyPlugin` is the name of the plugin module.
Path.join(["rel", "plugins", "*.exs"])
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    default_environment: Mix.env()

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html


# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  # If you are running Phoenix, you should make sure that
  # server: true is set and the code reloader is disabled,
  # even in dev mode.
  # It is recommended that you build with MIX_ENV=prod and pass
  # the --env flag to Distillery explicitly if you want to use
  # dev mode.
  set dev_mode: true
  set include_erts: false
  set cookie: :"yi?hzEQ{33t5WGxsrIF56(]^eR^yWDMlFKB:F,q:&M*UTa>hpw{>NcTJ3Wit7pRN"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"@x|YZ~YQ37?<N.7hbQv6H/grCH%a(?e8A5m/1)mq^>3M&HtXCC[I2xhGn^=BUO43"
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :gitlab_ci_monitor do
  set version: current_version(:gitlab_ci_monitor)
  set applications: [
    :runtime_tools
  ]
end

