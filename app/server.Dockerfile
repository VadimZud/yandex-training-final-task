FROM gcr.io/distroless/static-debian12:latest-amd64

WORKDIR /

COPY bingo bingo

EXPOSE 28940

USER nonroot:nonroot

ENTRYPOINT ["./bingo", "run_server"]