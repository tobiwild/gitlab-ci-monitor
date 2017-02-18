# Gitlab CI Monitor

[![Deps Status](https://beta.hexfaktor.org/badge/all/github/tobiwild/gitlab-ci-monitor.svg)](https://beta.hexfaktor.org/github/tobiwild/gitlab-ci-monitor)
[![devDependencies Status](https://david-dm.org/tobiwild/gitlab-ci-monitor/dev-status.svg)](https://david-dm.org/tobiwild/gitlab-ci-monitor?type=dev)


Small web app which lists Gitlab projects and their build status/progress. The goal is to teach myself Elixir, Phoenix and Elm.

It works like that:

* it uses multiple `GenServer` to fetch Gitlab projects, commits and pipelines periodically in different intervals
* it uses Phoenix channels to broadcast projects to Elm

## Docker Image

```
docker run \
    -e GITLAB_URL="http://gitlab.local/api/v3" \
    -e GITLAB_TOKEN=cw3beEjLvG294Zgyx58X \
    -e GITLAB_PROJECTS="root/test,root/test2" \
    -p 4000:4000 \
    tobiwild/gitlab-ci-monitor
```
