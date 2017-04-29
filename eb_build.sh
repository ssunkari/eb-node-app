#!/bin/bash

# usage:  -c ./eb_build.sh ${GO_PIPELINE_LABEL} ${AWS_ACCOUNT_ID} ${EB_APP_NAME} ${PORT}

SHA1=$1
AWS_ACCOUNT_ID=$2
EB_APP_NAME=$3
PORT=$4

sudo sed -i "s/EXPOSE [0-9]\+$/EXPOSE $PORT/" Dockerfile

aws configure set default.region eu-west-2

login_command=$(aws ecr get-login --profile eb-zuto-dev)

eval sudo $login_command

sudo docker build -t $EB_APP_NAME:$SHA1 .
sudo docker tag $EB_APP_NAME:$SHA1 $AWS_ACCOUNT_ID.dkr.ecr.eu-west-2.amazonaws.com/$EB_APP_NAME:$SHA1
# sudo docker run -i -a STDOUT --rm -e NODE_ENV=ci -e GO_PIPELINE_LABEL=$SHA1 $EB_APP_NAME:$SHA1 npm start
OUT=$?
if [ $OUT != 0 ]; then
	exit $OUT
fi

sudo docker push $AWS_ACCOUNT_ID.dkr.ecr.eu-west-2.amazonaws.com/$EB_APP_NAME:$SHA1
