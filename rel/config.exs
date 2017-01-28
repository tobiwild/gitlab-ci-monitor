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
    default_environment: :dev

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html


# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"BB]NomxaG1]pn$NN!CPLH!Y0P`hN^U>,~`QiiIfj}Fu1ZI8XR>|>NEQXS7z2WEB$"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"]z=?{^t<q~mAlu@;pj)5^:ULqr3@TGNG48<8%q[UKnJ7vzUBOha@Ua/=KN8Rs^$2"
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :gitlab_ci_monitor do
  set version: current_version(:gitlab_ci_monitor)
  set applications: [
    :gitlab_ci_monitor,
    tanuki: :load,
    exgravatar: :load
  ]
end

