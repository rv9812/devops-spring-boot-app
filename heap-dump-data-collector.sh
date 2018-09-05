#!/bin/bash
export AWS_DEFAULT_REGION=eu-west-1
export CLASSIC_LOADBALANCER=$1

wait_time=10
instance_id=$( /opt/aws/bin/ec2-metadata -i | awk '{print $2}' )
echo ${instance_id}

date=$(date +"%m-%d-%y")
echo $date

directory="/opt/app"
file="/opt/app/heap-dump.hprof"
if [ -d "$directory" ]
then

        if [ -f "$file" ]
        then
                        echo "$file found."
                        sleep ${wait_time}s
                        echo "waited $wait_time minutes"
                        response=$(aws s3 cp /opt/app/heap-dump.hprof s3://data39059812/${date}/${instance_id}/ --output text)
                        echo $response
                        aws elb deregister-instances-from-load-balancer --load-balancer-name ${CLASSIC_LOADBALANCER} --instances ${instance_id}
                        aws elb delete-load-balancer --load-balancer-name my-loadbalancer
                        aws ec2 terminate-instances --instance-ids ${instance_id}
        else
                        echo "$file not found."
        fi
else
        echo "$directory not found."
fi
