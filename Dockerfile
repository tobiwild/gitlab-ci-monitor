FROM alpine:3.4

RUN apk --update add ncurses-libs && rm -rf /var/cache/apk/*

ENV PORT=4000
EXPOSE $PORT

ADD rel/gitlab_ci_monitor.tar.gz /app/
WORKDIR /app

CMD ["/app/bin/gitlab_ci_monitor", "foreground"]
