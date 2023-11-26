FROM gcr.io/distroless/static-debian12:latest-amd64

WORKDIR /

COPY bingo bingo

USER nonroot:nonroot

ENTRYPOINT ["./bingo", "prepare_db"]