#!/usr/bin/env bash

export AWS_DEFAULT_REGION=eu-west-1

DOCKER_IMAGE=springboot
DOCKER_REGISTRY=devopstestapp
ACCOUNT_ID=071592233073

cd spring-boot-app/
./mvnw clean install
cd ..

docker build -t $DOCKER_IMAGE .

eval $(aws ecr get-login --region eu-west-1 --no-include-email | sed 's|https://||')
ecr_repo_exists=$(aws ecr describe-repositories | jq -r -c ".repositories[] | select(.repositoryName==\"$DOCKER_REGISTRY\") | .repositoryName")
if [ -z "$ecr_repo_exists" ]
then
        aws ecr create-repository --repository-name ${DOCKER_REGISTRY}
fi
docker tag $DOCKER_IMAGE:latest $ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/$DOCKER_REGISTRY:latest
docker push $ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/$DOCKER_REGISTRY:latest
