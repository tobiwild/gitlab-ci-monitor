# Gitlab CI Monitor

Small web app which lists Gitlab projects and their build status/progress. The goal is to teach myself Elixir, Phoenix and Elm.

It works like that:

* it uses multiple `GenServer` to fetch Gitlab projects, commits and pipelines periodically in different intervals
* it uses Phoenix channels to broadcast projects to Elm
