#!/bin/bash

source ./common.sh

check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "Adding mongo repo"

dnf install mongodb-org -y &>> $logs_file
validate $? "Install MongoDB"

systemctl enable mongod &>> $logs_file
systemctl start mongod &>> $logs_file
validate $? "Enable and start MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
validate $? "Updating remote connections to MongoDB"

systemctl restart mongod
validate $? "Restarting MongoDB"

# Displaying MongoDB Status
echo -e "\n${Y}--- MongoDB Service Status ---${N}"
systemctl status mongod --no-pager

# Wait for MongoDB to fully initialize
echo -e "\n${Y}--- Waiting 5 seconds for MongoDB to open port 27017... ---${N}"
sleep 5

# Displaying Port Listening Status
echo -e "\n${Y}--- MongoDB Port (27017) Listening Status ---${N}"
ss -lntp | grep 27017

total_time

