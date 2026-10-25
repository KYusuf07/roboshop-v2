#!/bin/bash

user_id=$(id -u)
logs_folder="/var/log/roboshop"
# Extract the script name properly for the log file
script_name=$(basename "$0")
logs_file="${logs_folder}/${script_name}.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $user_id -ne 0 ]; then
    echo -e "${R}Please run this script with sudo access..${N}"
    exit 1
fi

mkdir -p $logs_folder

timestamp(){
    date "+%F %T" 
}

echo "Script started execution at $(date +"%F %T")" &>> $logs_file

validate(){
    if [ $1 -ne 0 ]; then
        echo -e "${2}...${R}FAILED${N}" | tee -a $logs_file
        exit 1
    else
        echo -e "${2}...${G}SUCCESS${N}" | tee -a $logs_file
    fi  
}

echo "$(timestamp) [INFO] ==== Script started Execution =====" | tee -a $logs_file


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

echo "$(timestamp) [INFO] Script completed in $SECONDS seconds"
echo "$(timestamp) [INFO] ==== Script completed Execution =====" | tee -a $logs_file