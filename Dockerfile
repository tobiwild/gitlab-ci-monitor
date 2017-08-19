FROM alpine:3.6

RUN apk --update add \
    bash \
    openssl-dev \
    ncurses-libs && \
    rm -rf /var/cache/apk/*

ENV PORT=4000
EXPOSE $PORT

ADD rel/gitlab_ci_monitor.tar.gz /app/
WORKDIR /app

ENTRYPOINT ["/app/bin/gitlab_ci_monitor"]
CMD ["foreground"]
