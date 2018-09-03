#!/usr/bin/env bash

export AWS_DEFAULT_REGION=eu-west-1

echo aws cloudformation create-stack --stack-name $STACK_NAME --template-body file://mp-relay.json --parameters ParameterKey=S3BucketName,ParameterValue=${S3_BUCKET} ParameterKey=S3KeyName,ParameterValue=${ARTIFACTORY}/$PACKAGE  ParameterKey=ElasticKafkaBrokerAddress,ParameterValue=$ElasticKafkaBrokerAddress:9092 ParameterKey=EncryptionKeyId,ParameterValue=$EncryptionKeyId ParameterKey=ContainerImageURL,ParameterValue=$ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/$DOCKER_REGISTRY:latest ParameterKey=TaskVersion,ParameterValue=$BUILD_NUMBER  --capabilities CAPABILITY_NAMED_IAM
  response=$(aws cloudformation create-stack --stack-name $STACK_NAME --template-body file://ecs-fargate.json --capabilities CAPABILITY_NAMED_IAM)

  stack_id=$(echo $response | jq -r -c ".StackId" )

  aws cloudformation wait stack-create-complete --stack-name $stack_id 
  aws cloudformation describe-stack-events --region $AWS_DEFAULT_REGION --stack-name $stack_id 
