FROM debian

WORKDIR /

RUN ["adduser",  "--system", "--group", "--no-create-home", "nonroot"]

COPY bingo bingo

EXPOSE 28940

USER nonroot:nonroot

ENTRYPOINT ["/bin/sh", "-c", "./bingo run_server || exit 1"]