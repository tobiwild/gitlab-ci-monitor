#!/bin/sh
set -e

export MIX_ENV=prod
cp -a /workspace /build
cd /build

mix do deps.get, compile
# TODO: elm is not working in alpine container
#npm install
#npm run deploy
mix phx.digest
mix release --env=prod

cp /build/_build/prod/rel/gitlab_ci_monitor/releases/0.0.1/gitlab_ci_monitor.tar.gz /output
