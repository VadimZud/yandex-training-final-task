#!/bin/bash
POSTGRES_TAG=cr.yandex/$YC_CR_REGISTRY/bingo-postgres:latest
SERVER_TAG=cr.yandex/$YC_CR_REGISTRY/bingo-server:latest

docker build -t $POSTGRES_TAG -f $APP_PATH/postgres.Dockerfile $APP_PATH
docker build -t $SERVER_TAG -f $APP_PATH/server.Dockerfile $APP_PATH

docker image push $POSTGRES_TAG
docker image push $SERVER_TAG