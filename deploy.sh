#!/usr/bin/env bash

export AWS_DEFAULT_REGION=eu-west-1
STACK_NAME=test-cluster

echo aws cloudformation create-stack --stack-name test-cluster --template-body file://ecs-fargate.json  --parameters ParameterKey=ServiceName,ParameterValue=spring-boot-app --capabilities CAPABILITY_NAMED_IAM
response=$(aws cloudformation create-stack --stack-name $STACK_NAME --template-body file://ecs-fargate.json --parameters ParameterKey=ServiceName,ParameterValue=spring-boot-app --capabilities CAPABILITY_NAMED_IAM )

stack_id=$(echo $response | jq -r -c ".StackId" )
aws cloudformation wait stack-create-complete --stack-name $stack_id
aws cloudformation describe-stack-events --region $AWS_DEFAULT_REGION --stack-name $stack_id
