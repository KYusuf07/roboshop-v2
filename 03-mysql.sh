#!/bin/bash

source ./common.sh

check_root

dnf module enable mysql:8.4 -y &>> $logs_file
dnf install mysql-server -y  &>> $logs_file
validate $? "Installing MySQL server"

systemctl enable mysqld  &>> $logs_file
systemctl start mysqld
validate $? "Start and Enable MySQL"

mysql_secure_installation --set-root-pass RoboShop@1  &>> $logs_file
validate $? "Setup MySQL root password"

# Displaying Redis Status
echo -e "\n${Y}--- MySQL Service Status ---${N}"
systemctl status mysqld --no-pager

# Wait for MySQL to fully initialize
echo -e "\n${Y}--- Waiting 5 seconds for MySQL to open port 3306... ---${N}"
sleep 5

# Displaying Port Listening Status
echo -e "\n${Y}--- MySQL Port (6379) Listening Status ---${N}"
ss -lntp | grep 3306

total_time