INIT_TAG=cr.yandex/$YC_CR_REGISTRY/bingo-init:latest
SERVER_TAG=cr.yandex/$YC_CR_REGISTRY/bingo-server:latest

docker build -t $INIT_TAG -f $APP_PATH/init.Dockerfile $APP_PATH
docker build -t $SERVER_TAG -f $APP_PATH/server.Dockerfile $APP_PATH

docker image push $INIT_TAG
docker image push $SERVER_TAG