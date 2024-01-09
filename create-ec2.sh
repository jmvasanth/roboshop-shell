#!/bin/bash

#NAMES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
NAMES=$@
INSTANCE_TYPE=""
IMAGE_ID=ami-03265a0778a880afb
SECURITY_GROUP_ID=sg-0572c2ba2bf773656
DOMAIN_NAME=vgsk.online
HOSTED_ZONE_ID=Z0803879328RS2R0BHFXF

# If mysql and mongodb instance type is t3.medium, for all other it is t2.micro

for i in $@
do 
    if [[ $i == "mongodb" || $i == "mysql" ]]
    then
        INSTANCE_TYPE="t3.medium"
    else
        INSTANCE_TYPE="t2.micro"
    fi
    echo "Creating $i instance"
    IP_ADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID --instance-type $INSTANCE_TYPE --security-group-ids $SECURITY_GROUP_ID  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r '.Instances[0].PrivateIpAddress')
    echo "Created $i instance: $IP_ADDRESS"

    aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch '
    {
    "Changes":[
        {
            "Action":"CREATE",
            "ResourceRecordSet":{
                "Name":"'$i.$DOMAIN_NAME'",
                "Type":"A",
                "TTL":300,
                "ResourceRecords":[
                {
                    "Value":"'$IP_ADDRESS'"
                }
                ]
            }
        }
    ]
    }
    '
done
