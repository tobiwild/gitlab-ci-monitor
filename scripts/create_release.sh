#!/bin/bash
set -e

npm run deploy
docker run --rm -v $PWD:/workspace -v $PWD/rel:/output bitwalker/alpine-elixir /workspace/scripts/create_release_docker.sh
docker build -t tobiwild/gitlab-ci-monitor .
