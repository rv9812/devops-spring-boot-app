#!/bin/bash

instance_id=$( /opt/aws/bin/ec2-metadata -i | awk '{print $2}' )
echo ${instance_id}

date=$(date +"%m-%d-%y")
echo $date

file="/opt/app/heap-dump.hprof"
if [ -f "$file" ]
then
        echo "$file found."
        sleep 10m
        echo "waited 10 minutes"
        aws s3 cp /opt/app/heap-dump.hprof s3://ec2-heap-dump-data/${date}/instance-id/
        aws elb deregister-instances-from-load-balancer --load-balancer-name my-load-balancer --instances ${instance_id}
        aws elb delete-load-balancer --load-balancer-name my-load-balancer
        aws ec2 terminate-instances --instance-ids ${instance_id}
else
        echo "$file not found."
fi
