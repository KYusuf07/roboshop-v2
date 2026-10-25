#!/bin/bash

ami_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="vibelearning.online"
hosted_zone_id="Z0417239ES8HIRJNPWY7"

for instance in "$@"
do 
    echo "Creating instance: $instance" 

    instance_id=$(aws ec2 run-instances \
        --image-id $ami_id \
        --instance-type $instance_type \
        --security-groups --security-groups "MyIP" "MyIP" "$(case $instance in mongodb) echo MongoDB;; mysql) echo MySQL;; rabbitmq) echo RabbitMQ;; redis) echo Redis;; Catalogue) echo Catalogue;; user) echo User;; cart) echo Cart;; shipping) echo Shipping;; payment) echo Payment;; dispatch) echo Dispatch;; frontend) echo Frontend;; *) echo ${instance^};; esac)" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
        --query 'Instances[0].InstanceId' \
        --output text
    )

    echo "$instance ID: $instance_id"

    if [ "$instance" != "Frontend" ]; then
        IP=$(aws ec2 describe-instances --instance-ids $instance_id \
            --query 'Reservations[].Instances[].PrivateIpAddress' --output text
        )
        r53_record_name="$instance.$domain_name"
    else
        IP=$(aws ec2 describe-instances --instance-ids $instance_id \
            --query 'Reservations[].Instances[].PublicIpAddress' --output text
        )
        r53_record_name="$domain_name"
    fi
    echo "Record: ${r53_record}"
    echo "Creating Route53 Record: $r53_record_name with IP: $IP"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $hosted_zone_id \
    --change-batch '{
    "Changes": [
      {
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "'"$r53_record_name"'",
          "Type": "A",
          "TTL": 1,
          "ResourceRecords": [{"Value": "'"$IP"'"}]
        }
      }
    ]
  }'

  echo "Updated R53 record for $instance"
done