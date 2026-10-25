#!/bin/bash

source ./common.sh

check_root

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
validate $? "Adding RabbitMQ repo"

dnf install erlang rabbitmq-server -y &>> $logs_file
validate $? "Installing RabbitMQ server"

systemctl enable rabbitmq-server &>> $logs_file
systemctl start rabbitmq-server &>> $logs_file
validate $? "Starting and Enabling RabbitMQ Server"

rabbitmqctl list_users | grep -qw "roboshop"
if [ $? -ne 0 ]; then
    rabbitmqctl add_user roboshop roboshop123 &>> $logs_file
    validate $? "Creating RabbitMQ user for Roboshop"    
else
    echo -e "$(timestamp) [INFO] RabbitMQ user already exist...${Y}SKIPPING${N}" 
fi

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $logs_file
validate $? "Setting permissions for RabbitMQ user for Roboshop"

sudo rabbitmq-plugins enable rabbitmq_management &>> $logs_file
validate $? "Enabling RabbitMQ Management"

sudo rabbitmqctl set_user_tags roboshop administrator &>> $logs_file
validate $? "Setting tags for Roboshop administrator"


# Displaying Redis Status
echo -e "\n${Y}--- RabbitMQ Service Status ---${N}"
systemctl status rabbitmq-server --no-pager

# Wait for RabbitMQ to fully initialize
echo -e "\n${Y}--- Waiting 5 seconds for RabbitMQ to open port 27017... ---${N}"
sleep 5

# Displaying Port Listening Status
echo -e "\n${Y}--- RabbitMQ Port (6379) Listening Status ---${N}"
ss -lntp | grep 5672

total_time

