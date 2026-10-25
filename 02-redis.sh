#!/bin/bash

source ./common.sh

check_root

dnf module disable redis -y &>> $logs_file
dnf module enable redis:7 -y &>> $logs_file
dnf install redis -y &>> $logs_file
validate $? "Installing Redis"

sed -i -e 's/^bind 127.0.0.1/bind 0.0.0.0/' -e 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf
validate $? "Allowing remote connections to Redis"

systemctl enable redis &>> $logs_file
systemctl start redis
validate $? "Enable and start Redis"

# Displaying Redis Status
echo -e "\n${Y}--- Redis Service Status ---${N}"
systemctl status redis --no-pager

# Wait for Redis to fully initialize
echo -e "\n${Y}--- Waiting 5 seconds for Redis to open port 27017... ---${N}"
sleep 5

# Displaying Port Listening Status
echo -e "\n${Y}--- Redis Port (6379) Listening Status ---${N}"
ss -lntp | grep 6379

total_time