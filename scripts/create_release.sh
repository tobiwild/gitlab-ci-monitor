#!/bin/bash
set -e

(cd assets && npm run deploy)
docker run --rm -v $PWD:/workspace -v $PWD/rel:/output bitwalker/alpine-elixir:1.5.1 /workspace/scripts/create_release_docker.sh
docker build -t tobiwild/gitlab-ci-monitor .
