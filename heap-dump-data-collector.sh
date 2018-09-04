#!/bin/bash
instance_id=$( /opt/aws/bin/ec2-metadata -i | awk '{print $2}' )
echo ${instance_id}
export AWS_DEFAULT_REGION=eu-west-1

date=$(date +"%m-%d-%y")
echo $date

directory="/opt/app"
file="/opt/app/heap-dump.hprof"
if [ -d "$directory" ]
then

        if [ -f "$file" ]
        then
                        echo "$file found."
                        sleep 1m
                        echo "waited 10 minutes"
                        response=$(aws s3 cp /opt/app/heap-dump.hprof s3://data39059812/${date}/${instance_id}/)
                        echo "Upload successfully" ${response}
                        aws elb deregister-instances-from-load-balancer --load-balancer-name my-loadbalancer --instances ${instance_id}
                        aws elb delete-load-balancer --load-balancer-name my-loadbalancer
                        #aws ec2 terminate-instances --instance-ids ${instance_id}
        else
                        echo "$file not found."
        fi
else
        echo "$directory not found."
fi
