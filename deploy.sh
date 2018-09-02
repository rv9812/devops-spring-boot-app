#!/usr/bin/env bash
echo Download Artifactory
ARTIFACTORY=build-spark-stream-mo-relay
PACKAGE=package.zip

rm -fr ${ARTIFACTORY}
aws s3 cp s3://ccp-evtbu-artifactory/${ARTIFACTORY}/ ${ARTIFACTORY} --recursive

session_token=$(cat $BUILD_NUMBER)
export AWS_ACCESS_KEY_ID=$(echo $session_token | jq -r -c ".Credentials.AccessKeyId")
export AWS_SECRET_ACCESS_KEY=$(echo $session_token | jq -r -c ".Credentials.SecretAccessKey")
export AWS_SESSION_TOKEN=$(echo $session_token | jq -r -c ".Credentials.SessionToken")

echo Assumed Identity
identity=$(aws sts get-caller-identity)
echo $identity
ACCOUNT_ID=$(echo $identity | jq -r -c ".Account")
export AWS_DEFAULT_REGION=eu-west-1

echo Create S3 Buckets scripts: ${S3_BUCKET} 
bucket_exists=$(aws s3api list-buckets | jq -r -c ".Buckets[] | select(.Name==\"${S3Bucket}\") | .Name")
if [ -z "$bucket_exists" ] 
then
  aws s3api create-bucket --bucket ${S3_BUCKET} --region $AWS_DEFAULT_REGION --create-bucket-configuration LocationConstraint=$AWS_DEFAULT_REGION
fi

echo Copy scripts to S3 bucket
aws s3 cp ${ARTIFACTORY} s3://${S3_BUCKET}/${ARTIFACTORY}/ --recursive

ElasticKafkaBrokerAddress=$(aws cloudformation list-exports | jq -r -c ".Exports[] | select(.Name==\"runtime-evtbu-broker-KafkaBrokersLoadBalancerDNS\") | .Value")

if [ "$update_stack" = true ];
then
  echo aws cloudformation update-stack --stack-name $STACK_NAME --template-body file://mp-relay.json --parameters ParameterKey=S3BucketName,ParameterValue=${S3_BUCKET} ParameterKey=S3KeyName,ParameterValue=${ARTIFACTORY}/$PACKAGE  ParameterKey=ElasticKafkaBrokerAddress,ParameterValue=$ElasticKafkaBrokerAddress:9092 ParameterKey=EncryptionKeyId,ParameterValue=$EncryptionKeyId ParameterKey=ContainerImageURL,ParameterValue=$ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/$DOCKER_REGISTRY:latest ParameterKey=TaskVersion,ParameterValue=$BUILD_NUMBER  --capabilities CAPABILITY_NAMED_IAM
  response=$(aws cloudformation update-stack --stack-name $STACK_NAME --template-body file://mp-relay.json  --parameters ParameterKey=S3BucketName,ParameterValue=${S3_BUCKET} ParameterKey=S3KeyName,ParameterValue=${ARTIFACTORY}/$PACKAGE ParameterKey=ElasticKafkaBrokerAddress,ParameterValue=$ElasticKafkaBrokerAddress:9092 ParameterKey=EncryptionKeyId,ParameterValue=$EncryptionKeyId ParameterKey=ContainerImageURL,ParameterValue=$ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/$DOCKER_REGISTRY:latest ParameterKey=TaskVersion,ParameterValue=$BUILD_NUMBER  --capabilities CAPABILITY_NAMED_IAM)

  stack_id=$(echo $response | jq -r -c ".StackId" )

  aws cloudformation wait stack-update-complete --stack-name $stack_id
  aws cloudformation describe-stack-events --region $AWS_DEFAULT_REGION --stack-name $stack_id 
else
echo aws cloudformation create-stack --stack-name $STACK_NAME --template-body file://mp-relay.json --parameters ParameterKey=S3BucketName,ParameterValue=${S3_BUCKET} ParameterKey=S3KeyName,ParameterValue=${ARTIFACTORY}/$PACKAGE  ParameterKey=ElasticKafkaBrokerAddress,ParameterValue=$ElasticKafkaBrokerAddress:9092 ParameterKey=EncryptionKeyId,ParameterValue=$EncryptionKeyId ParameterKey=ContainerImageURL,ParameterValue=$ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/$DOCKER_REGISTRY:latest ParameterKey=TaskVersion,ParameterValue=$BUILD_NUMBER  --capabilities CAPABILITY_NAMED_IAM
  response=$(aws cloudformation create-stack --stack-name $STACK_NAME --template-body file://mp-relay.json  --parameters ParameterKey=S3BucketName,ParameterValue=${S3_BUCKET} ParameterKey=S3KeyName,ParameterValue=${ARTIFACTORY}/$PACKAGE ParameterKey=ElasticKafkaBrokerAddress,ParameterValue=$ElasticKafkaBrokerAddress:9092 ParameterKey=EncryptionKeyId,ParameterValue=$EncryptionKeyId ParameterKey=ContainerImageURL,ParameterValue=$ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/$DOCKER_REGISTRY:latest ParameterKey=TaskVersion,ParameterValue=$BUILD_NUMBER  --capabilities CAPABILITY_NAMED_IAM)

  stack_id=$(echo $response | jq -r -c ".StackId" )

  aws cloudformation wait stack-create-complete --stack-name $stack_id 
  aws cloudformation describe-stack-events --region $AWS_DEFAULT_REGION --stack-name $stack_id 

fi

