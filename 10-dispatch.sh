#!/bin/bash

user_id=$(id -u)
logs_folder="/var/log/roboshop"
logs_file="${logs_folder}/${0}.log"
domain_name="vibelearning.online"
scripts_dir=$(dirname "$(realpath "$0")")
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

validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$(timestamp) [ERROR] ${2}..${R}FAILED${N}" | tee -a $logs_file
        exit 1
    else
        echo -e "$(timestamp) [INFO] ${2}..${G}SUCCESS${N}" | tee -a $logs_file
    fi
}

echo "$(timestamp) [INFO] ==== Script started Execution =====" | tee -a $logs_file

# Install Go
dnf install golang -y &>> $logs_file
validate $? "Installing GoLang"

# Create roboshop user
id roboshop &>> $logs_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $logs_file
    validate $? "Creating system user"
else
    echo -e "$(timestamp) [INFO] System user roboshop already exist...${Y}SKIPPING${N}"
fi

rm -rf /app &>> $logs_file
validate $? "Removing old code"

mkdir -p /app &>> $logs_file
validate $? "Creating app directory"

# Download and Unzip Application
curl -L -o /tmp/dispatch.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/dispatch-v4.zip &>> $logs_file
validate $? "Downloading dispatch code"

cd /app || exit
unzip -o /tmp/dispatch.zip &>> $logs_file
validate $? "Unzipping dispatch code"

# Build the Go Application
go build -o dispatch . &>> $logs_file
validate $? "Building Dispatch Application (Go)"

# Copy SystemD Service File from your scripts directory
cp "$scripts_dir/dispatch.service" /etc/systemd/system/dispatch.service
validate $? "Copying dispatch.service file"

# Replace the DOMAIN_NAME placeholder with your actual domain variable
sed -i "s/DOMAIN_NAME/$domain_name/g" /etc/systemd/system/dispatch.service
validate $? "Configuring dispatch.service domain name"

# Start and Enable Service
systemctl daemon-reload &>> $logs_file
systemctl enable dispatch &>> $logs_file
systemctl restart dispatch &>> $logs_file
validate $? "Restarting and enabling dispatch"

echo "$(timestamp) [INFO] Script completed in $SECONDS seconds"
echo "$(timestamp) [INFO] ==== Script completed Execution =====" | tee -a $logs_file

# ==========================================
# VERIFICATIONS
# ==========================================

# 1. Check Service Status
echo -e "\n${Y}--- Dispatch Service Status ---${N}"
systemctl status dispatch --no-pager

# 2. Check Recent Logs (last 20 lines)
echo -e "\n${Y}--- Recent Dispatch Logs ---${N}"
journalctl -u dispatch -n 20 --no-pager