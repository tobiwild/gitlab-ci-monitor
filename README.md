# Gitlab CI Monitor

[![Deps Status](https://beta.hexfaktor.org/badge/all/github/tobiwild/gitlab-ci-monitor.svg)](https://beta.hexfaktor.org/github/tobiwild/gitlab-ci-monitor)
[![devDependencies Status](https://david-dm.org/tobiwild/gitlab-ci-monitor/dev-status.svg?path=assets)](https://david-dm.org/tobiwild/gitlab-ci-monitor?path=assets&type=dev)

Small web app which lists Gitlab projects and their build status/progress. The goal is to teach myself Elixir, Phoenix and Elm.

![Screenshot](screenshot.png?raw=true)

It works like this:

* it uses multiple `GenServer` to fetch Gitlab projects, commits and pipelines periodically in different intervals
* it uses Phoenix channels to broadcast projects to Elm

## Development

Dependencies: `pacman -S elixir npm`

Setup a Gitlab instance (API v4 required) like so:

    docker run -d \
        --hostname gitlab.local \
        -v gitlab_data:/var/opt/gitlab \
        -v gitlab_config:/etc/gitlab \
        --name gitlab \
        -p 80:80 \
        -p 2222:22 \
        gitlab/gitlab-ce

Start some runners:

    docker run -d --name gitlab-runner --link gitlab:gitlab.local gitlab/gitlab-runner:latest
    docker run -d --name gitlab-runner2 --link gitlab:gitlab.local gitlab/gitlab-runner:latest

Then setup some projects with pipelines enabled.

Install and start the app:

    mix deps.get
    (cd assets && npm install)

    GITLAB_URL="http://gitlab.local/api/v4" \
    GITLAB_TOKEN=cw3beejlvg294zgyx58x \
    GITLAB_PROJECTS="root/test,root/test2" \
        mix phx.server

## Docker Image

```
docker run \
    -e GITLAB_URL="http://gitlab.local/api/v4" \
    -e GITLAB_TOKEN=cw3beejlvg294zgyx58x \
    -e GITLAB_PROJECTS="root/test,root/test2" \
    -p 4000:4000 \
    tobiwild/gitlab-ci-monitor
```
